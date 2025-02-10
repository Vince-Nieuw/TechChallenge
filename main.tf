terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.16"
    }
  }

  required_version = ">= 1.2.0"
}

provider "aws" {
  region  = "eu-north-1"
  profile = "vince-1"
}

resource "aws_instance" "hello_world" {
  ami           = "ami-08b1d20c6a69a7100"
  instance_type = "t3.micro"

  tags = {
    Name = "TechChallenge"
  }
}
