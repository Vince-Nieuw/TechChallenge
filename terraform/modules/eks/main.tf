# Create EKS Cluster
module "eks" {
  source = "terraform-aws-modules/eks/aws"
  cluster_name = "web-application-cluster"
  cluster_version = "1.21"
  subnet_ids = [var.public_subnet_id, var.private_subnet_id]
  vpc_id = var.vpc_id
  eks_managed_node_groups = {
    eks_nodes = {
      desired_capacity = 2
      max_capacity     = 3
      min_capacity     = 1
      instance_type    = "t3.medium"
    }
  }
}

variable "vpc_id" {
  description = "VPC ID for the EKS Cluster"
  type        = string
}

variable "public_subnet_id" {
  description = "Public subnet ID for the EKS Cluster"
  type        = string
}

variable "private_subnet_id" {
  description = "Private subnet ID for the EKS Cluster"
  type        = string
}

