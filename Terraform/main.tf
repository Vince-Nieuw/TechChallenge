terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.16"
    }
  }

  required_version = ">= 1.2.0"
}

resource "aws_instance" "hello_world" {
  ami           = "ami-08b1d20c6a69a7100"
  instance_type = "t3.micro"

  tags = {
    Name = "TechChallenge"
  }
}

