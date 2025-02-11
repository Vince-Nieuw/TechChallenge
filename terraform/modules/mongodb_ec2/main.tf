variable "vpc_id" {
  description = "VPC ID where the MongoDB EC2 instance will be deployed"
  type        = string
}

resource "aws_instance" "mongodb" {
  ami                       = "ami-08b1d20c6a69a7100"  # Update with the appropriate AMI
  instance_type             = "t3.micro"
  subnet_id                 = var.private_subnet_id
  vpc_security_group_ids    = [var.security_group_id]
  key_name                  = "mongodb-key"  # Replace with your actual key pair

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

variable "mongodb_admin_user" {
  description = "MongoDB admin username"
  type        = string
}

variable "mongodb_admin_password" {
  description = "MongoDB admin password"
  type        = string
}

variable "private_subnet_id" {
  description = "The ID of the private subnet where the EC2 instance will run"
  type        = string
}

variable "security_group_id" {
  description = "The security group ID to associate with the MongoDB EC2 instance"
  type        = string
}

