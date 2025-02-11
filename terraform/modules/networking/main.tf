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
#  Subnet Creation
# ===========================

# Public Subnet (For Bastion Host & Load Balancer)
resource "aws_subnet" "public" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = "10.0.1.0/24"
  availability_zone       = "eu-north-1a"
  map_public_ip_on_launch = true

  tags = {
    Name = "Public-Subnet"
  }
}

# Private Subnet (For MongoDB & EKS)
resource "aws_subnet" "private" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = "10.0.2.0/24"
  availability_zone = "eu-north-1a"

  tags = {
    Name = "Private-Subnet"
  }
}

# ===========================
#  Internet Gateway (For Public Subnet)
# ===========================
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "Internet-Gateway"
  }
}

# Route Table for Public Subnet
resource "aws_route_table" "public_rt" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }

  tags = {
    Name = "Public-Route-Table"
  }
}

# Associate Public Subnet with Public Route Table
resource "aws_route_table_association" "public" {
  subnet_id      = aws_subnet.public.id
  route_table_id = aws_route_table.public_rt.id
}

# ===========================
#  NAT Gateway (For Private Subnet)
# ===========================
resource "aws_eip" "nat_eip" {
  domain = "vpc"
}

resource "aws_nat_gateway" "nat" {
  allocation_id = aws_eip.nat_eip.id
  subnet_id     = aws_subnet.public.id

  tags = {
    Name = "NAT-Gateway"
  }
}

# Route Table for Private Subnet (Using NAT Gateway)
resource "aws_route_table" "private_rt" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.nat.id
  }

  tags = {
    Name = "Private-Route-Table"
  }
}

# Associate Private Subnet with Private Route Table
resource "aws_route_table_association" "private" {
  subnet_id      = aws_subnet.private.id
  route_table_id = aws_route_table.private_rt.id
}

# ===========================
#  Security Groups
# ===========================

# Security Group for MongoDB (Restrict Access to VPC)
resource "aws_security_group" "mongodb_sg" {
  name        = "mongodb-sg"
  description = "Allow MongoDB traffic only within VPC"
  vpc_id      = aws_vpc.main.id

  # Allow only internal VPC traffic for MongoDB
  ingress {
    from_port   = 27017
    to_port     = 27017
    protocol    = "tcp"
    cidr_blocks = ["10.0.0.0/16"]
  }

  # Allow SSH from Bastion Host (Public Subnet)
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["10.0.1.0/24"]  # Public Subnet CIDR
  }

  # Allow all outbound traffic
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "MongoDB-SG"
  }
}

# Security Group for Bastion Host (Allow Public SSH)
resource "aws_security_group" "bastion_sg" {
  name        = "bastion-sg"
  description = "Allow SSH from Internet"
  vpc_id      = aws_vpc.main.id

  # Allow SSH from any IP (for testing, restrict in production)
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Allow all outbound traffic
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "Bastion-SG"
  }
}

# Security Group for EKS Nodes (Allow External Access)
resource "aws_security_group" "eks_sg" {
  name        = "eks-sg"
  description = "Allow traffic to EKS"
  vpc_id      = aws_vpc.main.id

  # Allow HTTP/S Traffic for Web Application
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Allow all outbound traffic
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "EKS-SG"
  }
}

# ===========================
#  Outputs
# ===========================

output "vpc_id" {
  value = aws_vpc.main.id
}

output "public_subnet_id" {
  value = aws_subnet.public.id
}

output "private_subnet_id" {
  value = aws_subnet.private.id
}

output "mongodb_sg_id" {
  value = aws_security_group.mongodb_sg.id
}

output "bastion_sg_id" {
  value = aws_security_group.bastion_sg.id
}

output "eks_sg_id" {
  value = aws_security_group.eks_sg.id
}

