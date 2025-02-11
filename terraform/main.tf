provider "aws" {
}

resource "aws_vpc" "main" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_support   = true
  enable_dns_hostnames = true
}

resource "aws_subnet" "public" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = "10.0.1.0/24"
  availability_zone       = "eu-north-1a"
  map_public_ip_on_launch = true
}

resource "aws_subnet" "private" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = "10.0.2.0/24"
  availability_zone = "eu-north-1a"
}

resource "aws_security_group" "mongodb_sg" {
  name        = "mongodb-sg"
  description = "Allow MongoDB traffic"
  vpc_id      = aws_vpc.main.id

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 27017
    to_port     = 27017
    protocol    = "tcp"
    cidr_blocks = ["10.0.0.0/16"]
  }
}

resource "aws_s3_bucket" "mongodb_backup" {
  bucket = "mongodb-backup-bucket-unique-12345"
}

module "ec2-mongodb" {
  source            = "./modules/ec2-mongodb"
  vpc_id            = aws_vpc.main.id
  private_subnet_id = aws_subnet.private.id
  public_subnet_id  = aws_subnet.public.id
  mongodb_s3_bucket = aws_s3_bucket.mongodb_backup.id

