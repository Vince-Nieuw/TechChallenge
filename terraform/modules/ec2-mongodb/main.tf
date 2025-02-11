resource "aws_key_pair" "mongodb_key" {
  key_name   = "mongodb-key"
  public_key = file("~/.ssh/id_rsa.pub") # Ensure you have an SSH key generated
}

resource "aws_instance" "mongodb" {
  ami           = "ami-08b1d20c6a69a7100"  # Ubuntu 22.04 AMI for eu-north-1
  instance_type = "t3.micro"
  subnet_id     = var.private_subnet_id
  vpc_security_group_ids = [aws_security_group.mongodb_sg.id]
  iam_instance_profile = aws_iam_instance_profile.mongodb_backup_profile.name
  key_name      = aws_key_pair.mongodb_key.key_name

  user_data = <<-EOF
              #!/bin/bash
              sudo apt update
              sudo apt install -y mongodb
              sudo systemctl enable mongodb
              sudo systemctl start mongodb

              # Configure MongoDB authentication
              echo "setting up MongoDB authentication"
              sudo sed -i 's/#security:/security:\n  authorization: enabled/' /etc/mongod.conf
              sudo systemctl restart mongodb

              # Set up automatic backups to S3
              echo "0 0 * * * mongodump --out /var/backups/mongo && aws s3 cp /var/backups/mongo s3://${var.mongodb_s3_bucket}/" | crontab -
              EOF

  tags = {
    Name = "MongoDB-Server"
  }
}

resource "aws_security_group" "mongodb_sg" {
  vpc_id = var.vpc_id

  # Allow MongoDB access only from within the VPC
  ingress {
    from_port   = 27017
    to_port     = 27017
    protocol    = "tcp"
    cidr_blocks = ["10.0.0.0/16"]
  }

  # Allow SSH from the public internet (restricted)
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Allow outbound traffic
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_s3_bucket" "mongodb_backup" {
  bucket = var.mongodb_s3_bucket
  acl    = "private"
  force_destroy = true

  tags = {
    Name = "MongoDB Backup Bucket"
  }
}

resource "aws_iam_role" "mongodb_backup_role" {
  name = "MongoDBBackupRole"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Principal = { Service = "ec2.amazonaws.com" }
      Action = "sts:AssumeRole"
    }]
  })
}

resource "aws_iam_policy" "s3_backup_policy" {
  name = "MongoDBS3BackupPolicy"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Action = ["s3:PutObject"]
      Resource = "arn:aws:s3:::${var.mongodb_s3_bucket}/*"
    }]
  })
}

resource "aws_iam_role_policy_attachment" "s3_backup_attach" {
  role       = aws_iam_role.mongodb_backup_role.name
  policy_arn = aws_iam_policy.s3_backup_policy.arn
}

resource "aws_iam_instance_profile" "mongodb_backup_profile" {
  name = "MongoDBBackupProfile"
  role = aws_iam_role.mongodb_backup_role.name
}

