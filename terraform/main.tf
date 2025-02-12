terraform {
  backend "s3" {
    bucket         = "terraform-remote-state-s3-vincenieuw2"
    key            = "terraform.tfstate"
    region         = "us-east-1"  # Changed region to us-east-1
    dynamodb_table = "terraform-locks"
    encrypt        = true
  }
}

provider "aws" {
  region = "us-east-1"  # Changed region to us-east-1
}

# ===========================
#  Variables
# ===========================

variable "mongodb_admin_user" {
  description = "MongoDB admin username"
  type        = string
  default     = "admin"
}

variable "mongodb_admin_password" {
  description = "MongoDB admin password"
  type        = string
  default     = "SuperSecretPass123"
}

# ===========================
#  VPC Creation
# ===========================

resource "aws_vpc" "main" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name = "Main-VPC"
  }
}

# ===========================
#  Public Subnets (For Bastion)
# ===========================

resource "aws_subnet" "public_1" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = "10.0.1.0/24"
  availability_zone       = "us-east-1a"
  map_public_ip_on_launch = true

  tags = {
    Name = "Public-Subnet-1"
  }
}

resource "aws_subnet" "public_2" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = "10.0.2.0/24"
  availability_zone       = "us-east-1b"
  map_public_ip_on_launch = true

  tags = {
    Name = "Public-Subnet-2"
  }
}

# ===========================
#  Private Subnets (For MongoDB)
# ===========================

resource "aws_subnet" "private_1" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = "10.0.3.0/24"
  availability_zone = "us-east-1a"

  tags = {
    Name = "Private-Subnet-1"
  }
}

resource "aws_subnet" "private_2" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = "10.0.4.0/24"
  availability_zone = "us-east-1b"

  tags = {
    Name = "Private-Subnet-2"
  }
}

# ===========================
#  Security Groups
# ===========================

resource "aws_security_group" "mongodb_sg" {
  vpc_id = aws_vpc.main.id

  ingress {
    from_port   = 27017
    to_port     = 27017
    protocol    = "tcp"
    cidr_blocks = ["10.0.0.0/16"]  # Allow only VPC traffic
  }

  tags = {
    Name = "MongoDB-SG"
  }
}

resource "aws_security_group" "bastion_sg" {
  vpc_id = aws_vpc.main.id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]  # Allow SSH from anywhere
  }

  tags = {
    Name = "Bastion-SG"
  }
}

# ===========================
#  MongoDB EC2 Instance
# ===========================

resource "aws_instance" "mongodb" {
  ami                    = "ami-08b1d20c6a69a7100"
  instance_type          = "t3.micro"
  subnet_id              = aws_subnet.private_1.id
  vpc_security_group_ids = [aws_security_group.mongodb_sg.id]
  key_name               = "mongodb-key"

  tags = {
    Name = "MongoDB-Server"
  }
}

# ===========================
#  Bastion Host
# ===========================

resource "aws_instance" "bastion" {
  ami                        = "ami-08b1d20c6a69a7100"
  instance_type              = "t3.micro"
  subnet_id                  = aws_subnet.public_1.id
  associate_public_ip_address = true
  key_name                   = "techchallenge-2"
  vpc_security_group_ids      = [aws_security_group.bastion_sg.id]

  tags = {
    Name = "Bastion-Host"
  }
}

# ===========================
#  S3 Bucket for Backups
# ===========================

resource "aws_s3_bucket" "mongodb_backups" {
  bucket = "mongodb-backups-bucket-vincenieuw"  # Make sure this is globally unique
  acl    = "private"

  tags = {
    Name = "MongoDB-Backups"
  }
}

