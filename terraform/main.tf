terraform {
  backend "s3" {
    bucket         = "terraform-remote-state-s3-vincenieuw2"
    key            = "terraform.tfstate"
    region         = "us-east-1"
    dynamodb_table = "terraform-locks"
    encrypt        = true
  }
}

provider "aws" {
  region = "us-east-1"
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
    Name = "Techchallenge-VPC"
  }
}

# ===========================
#  Public Subnets (For Bastion and MongoDB)
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
#  Private Subnets
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

  # Ingress rule for MongoDB (port 27017 for VPC traffic)
  ingress {
    from_port   = 27017
    to_port     = 27017
    protocol    = "tcp"
    cidr_blocks = ["10.0.0.0/16"]  # Allow traffic only from VPC
  }

  # Ingress rule for SSH (port 22) from everyone
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]  # Allow SSH from anywhere
  }

  # Outbound rule for all traffic to anywhere (0.0.0.0/0)
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"  # Allow all outbound traffic
    cidr_blocks = ["0.0.0.0/0"]
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

  # Outbound rule for server updates (allow all outbound traffic)
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"  # Allow all outbound traffic
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "Bastion-SG"
  }
}

# ===========================
#  SSH Key Pair (Local Public Key)
# ===========================

resource "aws_key_pair" "my_ssh_key" {
  key_name   = "my-ssh-key"  # Name you want to assign to the key in AWS
  public_key = file("~/.ssh/id_rsa.pub")  # Path to your existing public key
}

# ===========================
#  IAM Role and Policy for MongoDB Instance
# ===========================

resource "aws_iam_role" "mongodb_role" {
  name = "mongodb-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
        Action = "sts:AssumeRole"
      }
    ]
  })

  tags = {
    Name = "MongoDB-Role"
  }
}

resource "aws_iam_policy" "mongodb_policy" {
  name        = "mongodb-policy"
  description = "Policy to allow EC2 actions"
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "ec2:*"
        Effect = "Allow"
        Resource = "*"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "mongodb_policy_attachment" {
  role       = aws_iam_role.mongodb_role.name
  policy_arn = aws_iam_policy.mongodb_policy.arn
}

resource "aws_iam_instance_profile" "mongodb_instance_profile" {
  name = "mongodb-instance-profile"
  role = aws_iam_role.mongodb_role.name
}

# ===========================
#  MongoDB EC2 Instance
# ===========================

resource "aws_instance" "mongodb" {
  ami                    = "ami-04b4f1a9cf54c11d0"
  instance_type          = "t3.micro"
  subnet_id              = aws_subnet.public_1.id  # Change to public subnet
  vpc_security_group_ids = [aws_security_group.mongodb_sg.id]
  key_name               = aws_key_pair.my_ssh_key.key_name  # Use the key pair created by Terraform
  iam_instance_profile   = aws_iam_instance_profile.mongodb_instance_profile.name  # Attach IAM instance profile

  tags = {
    Name = "MongoDB-Server"
  }
}

# ===========================
#  Bastion Host EC2 Instance
# ===========================

resource "aws_instance" "bastion" {
  ami                        = "ami-04b4f1a9cf54c11d0"
  instance_type              = "t3.micro"
  subnet_id                  = aws_subnet.public_1.id
  associate_public_ip_address = false  # Disable auto-assignment of public IP
  key_name                   = aws_key_pair.my_ssh_key.key_name  # Use the key pair created by Terraform
  vpc_security_group_ids      = [aws_security_group.bastion_sg.id]

  tags = {
    Name = "Bastion-Host"
  }
}

# ===========================
#  Internet Gateway for VPC
# ===========================

resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "Main-Internet-Gateway"
  }
}

# ===========================
#  Elastic IP for Bastion
# ===========================

resource "aws_eip_association" "bastion_eip_association" {
  instance_id   = aws_instance.bastion.id
  allocation_id = "eipalloc-0f10891ac9d70093d"  # Use your pre-allocated Elastic IP allocation ID
}

# ===========================
#  Create NAT Gateway
# ===========================

resource "aws_eip" "nat_eip" {
  vpc = true
}

resource "aws_nat_gateway" "nat" {
  allocation_id = aws_eip.nat_eip.id
  subnet_id     = aws_subnet.public_1.id

  tags = {
    Name = "NAT-Gateway"
  }
}

# ===========================
#  Route Table for Private Subnets (Route Outbound Traffic to NAT Gateway)
# ===========================

resource "aws_route_table" "private" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block    = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.nat.id  # Route private subnet traffic to NAT Gateway
  }

  tags = {
    Name = "Private-Route-Table"
  }
}

# ===========================
#  Associate Private Subnets with Route Table
# ===========================

resource "aws_route_table_association" "private_subnet_1" {
  subnet_id      = aws_subnet.private_1.id
  route_table_id = aws_route_table.private.id
}

resource "aws_route_table_association" "private_subnet_2" {
  subnet_id      = aws_subnet.private_2.id
  route_table_id = aws_route_table.private.id
}

# ===========================
#  Output Elastic IP Address
# ===========================

output "bastion_elastic_ip" {
  value       = "44.213.83.93"  # The static Elastic IP you have allocated
  description = "The Elastic IP address of the Bastion host"
}

# ===========================
#  Create Route Table for Public Subnets (with Route to Internet Gateway)
# ===========================

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.main.id
  }

  tags = {
    Name = "Public-Route-Table"
  }
}

# ===========================
#  Associate Public Subnets with Route Table
# ===========================

resource "aws_route_table_association" "public_subnet_1" {
  subnet_id      = aws_subnet.public_1.id
  route_table_id = aws_route_table.public.id
}

resource "aws_route_table_association" "public_subnet_2" {
  subnet_id      = aws_subnet.public_2.id
  route_table_id = aws_route_table.public.id
}
