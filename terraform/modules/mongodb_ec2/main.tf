# ===========================
#  Variables
# ===========================

variable "vpc_id" {
  description = "VPC ID where MongoDB EC2 instance will be deployed"
  type        = string
}

variable "private_subnet_id" {
  description = "The ID of the private subnet where the MongoDB EC2 instance will run"
  type        = string
}

variable "mongodb_admin_user" {
  description = "MongoDB admin username"
  type        = string
}

variable "mongodb_admin_password" {
  description = "MongoDB admin password"
  type        = string
}

variable "security_group_id" {
  description = "The security group ID to associate with the MongoDB EC2 instance"
  type        = string
}

# ===========================
#  EC2 Key Pair for SSH Access
# ===========================

resource "aws_key_pair" "mongodb_key" {
  key_name   = "mongodb-key"
  public_key = file("~/.ssh/id_rsa.pub")  # Ensure you have a valid public key here
}

# ===========================
#  MongoDB EC2 Instance
# ===========================

resource "aws_instance" "mongodb" {
  ami                    = "ami-08b1d20c6a69a7100"  # Ensure this is a valid AMI for your region
  instance_type          = "t3.micro"
  subnet_id              = var.private_subnet_id
  vpc_security_group_ids = [var.security_group_id]
  key_name               = aws_key_pair.mongodb_key.key_name  # ✅ Fixes missing key pair error

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

# ===========================
#  Outputs
# ===========================

output "mongodb_instance_id" {
  value = aws_instance.mongodb.id
}

