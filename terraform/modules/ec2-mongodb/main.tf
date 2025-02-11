resource "aws_key_pair" "mongodb_key" {
  key_name   = "mongodb-key"
  public_key = file("~/.ssh/id_rsa.pub") 
}

resource "aws_instance" "mongodb" {
  ami           = "ami-08b1d20c6a69a7100"  #Ubuntu (same as Github runner) 
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

resource "aws_s3_bucket" "mongodb_backup" {
  bucket = var.mongodb_s3_bucket
  acl    = "private"
  force_destroy = true

  tags = {
    Name = "MongoDB Backup Bucket"
  }
}

resource "aws_security_group" "mongodb_sg" {
  vpc_id = var.vpc_id

  # Allow MongoDB access only from the Bastion Host
  ingress {
    from_port   = 27017
    to_port     = 27017
    protocol    = "tcp"
    cidr_blocks = [aws_instance.bastion.public_ip]
  }

  # Allow outbound traffic
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_instance" "bastion" {
  ami           = "ami-08b1d20c6a69a7100"  # Ubuntu 22.04 for eu-north-1
  instance_type = "t3.micro"
  subnet_id     = var.public_subnet_id
  associate_public_ip_address = true
  vpc_security_group_ids = [aws_security_group.bastion_sg.id]
  key_name = aws_key_pair.mongodb_key.key_name

  tags = {
    Name = "Bastion-Host"
  }
}

resource "aws_security_group" "bastion_sg" {
  vpc_id = var.vpc_id

# Curious if AWS Config or Wiz will pick this up. //TODO fix open to internet. 
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
