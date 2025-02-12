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
#  Public Subnets (For EKS & Bastion)
# ===========================

resource "aws_subnet" "public_1" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = "10.0.1.0/24"
  availability_zone       = "eu-north-1a"
  map_public_ip_on_launch = true

  tags = {
    Name = "Public-Subnet-1"
  }
}

resource "aws_subnet" "public_2" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = "10.0.2.0/24"
  availability_zone       = "eu-north-1b"
  map_public_ip_on_launch = true

  tags = {
    Name = "Public-Subnet-2"
  }
}

# ===========================
#  Private Subnets (For MongoDB & EKS)
# ===========================

resource "aws_subnet" "private_1" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = "10.0.3.0/24"
  availability_zone = "eu-north-1a"

  tags = {
    Name = "Private-Subnet-1"
  }
}

resource "aws_subnet" "private_2" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = "10.0.4.0/24"
  availability_zone = "eu-north-1b"

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
#  Outputs (Only If Required)
# ===========================

output "vpc_id" {
  value = aws_vpc.main.id
}

output "public_subnet_id_1" {
  value = aws_subnet.public_1.id
}

output "public_subnet_id_2" {
  value = aws_subnet.public_2.id
}

output "private_subnet_id_1" {
  value = aws_subnet.private_1.id
}

output "private_subnet_id_2" {
  value = aws_subnet.private_2.id
}

output "mongodb_sg_id" {
  value = aws_security_group.mongodb_sg.id
}

output "bastion_sg_id" {
  value = aws_security_group.bastion_sg.id
}

