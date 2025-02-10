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
  region  = "eu-west-1"
  profile = "vince-euwest1"
}

resource "aws_instance" "hello_world" {
  ami           = "ami-0298982da8499a634"
  instance_type = "t2.micro"

  tags = {
    Name = "TechChallenge"
  }
}
