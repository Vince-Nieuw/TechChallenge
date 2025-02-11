resource "aws_instance" "bastion" {
  ami                        = "ami-08b1d20c6a69a7100"  # Update with the appropriate AMI
  instance_type              = "t3.micro"
  subnet_id                  = var.public_subnet_id
  associate_public_ip_address = true
  key_name                   = "techchallenge-2"  
  vpc_security_group_ids     = [var.security_group_id]

  tags = {
    Name = "Bastion-Host"
  }
}

variable "public_subnet_id" {
  description = "The ID of the public subnet for Bastion"
  type        = string
}

variable "security_group_id" {
  description = "The security group ID to associate with the Bastion host"
  type        = string
}

variable "vpc_id" {
  description = "The ID of the VPC"
  type        = string
}

