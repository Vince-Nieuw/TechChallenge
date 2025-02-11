# TechChallenge/terraform/modules/ec2-mongodb/main.tf

resource "aws_security_group" "mongodb_sg" {
  vpc_id = var.vpc_id

  # Allow MongoDB access only within the VPC
  ingress {
    from_port   = 27017
    to_port     = 27017
    protocol    = "tcp"
    cidr_blocks = [var.vpc_cidr]
  }

  # Allow SSH from anywhere (temporarily for testing, restrict later)
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

resource "aws_key_pair" "mongodb_key" {
  key_name   = "mongodb-key"
  public_key = file("~/.ssh/id_rsa.pub")
}

resource "aws_instance" "mongodb" {
  ami           = "ami-08b1d20c6a69a7100"
  instance_type = "t3.micro"
  subnet_id     = var.private_subnet_id
  vpc_security_group_ids = [aws_security_group.mongodb_sg.id]
  key_name      = aws_key_pair.mongodb_key.key_name

  user_data = <<-EOF
              #!/bin/bash
              sudo apt update
              sudo apt install -y mongodb
              sudo systemctl enable mongodb
              sudo systemctl start mongodb

              MONGO_USER="${var.mongodb_admin_user}"
              MONGO_PASSWORD="${var.mongodb_admin_password}"
              mongo --eval "db.createUser({user: '$MONGO_USER', pwd: '$MONGO_PASSWORD', roles:[{role:'root', db:'admin'}]})"
              EOF

  tags = {
    Name = "MongoDB-Server"
  }
}

resource "aws_instance" "bastion" {
  ami           = "ami-08b1d20c6a69a7100"
  instance_type = "t3.micro"
  subnet_id     = var.public_subnet_id
  associate_public_ip_address = true
  key_name = aws_key_pair.mongodb_key.key_name
  vpc_security_group_ids = [aws_security_group.mongodb_sg.id]

  tags = {
    Name = "Bastion-Host"
  }
}

resource "aws_s3_bucket" "mongodb_backup" {
  bucket = var.mongodb_s3_bucket
  force_destroy = true

  tags = {
    Name = "MongoDB Backup Bucket"
  }
}

resource "aws_s3_bucket_acl" "mongodb_backup_acl" {
  bucket = aws_s3_bucket.mongodb_backup.id
  acl    = "private"
}


