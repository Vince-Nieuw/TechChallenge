# ===========================
#  Create EKS Cluster
# ===========================

module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "19.12.0"

  cluster_name    = "web-application-cluster"
  cluster_version = "1.27" # Updated version

# Have to update control plane to 2 AZ's.
  subnet_ids = [var.public_subnet_id_1, var.public_subnet_id_2]
  vpc_id     = var.vpc_id

  eks_managed_node_groups = {
    eks_nodes = {
      desired_capacity = 1  # Scale down to 1 for cost perspectvie
      max_capacity     = 1
      min_capacity     = 1
      instance_types   = ["t3.medium"]
      subnet_ids       = [var.private_subnet_id_1]  # I just want 1 node in 1 subnet, but EKS needs control plane spread over 2. This locks to 1. 
    }
  }
}

# ===========================
#  Variables
# ===========================

variable "vpc_id" {
  description = "VPC ID for the EKS Cluster"
  type        = string
}

variable "public_subnet_id_1" {
  description = "First public subnet ID for the EKS Cluster"
  type        = string
}

variable "public_subnet_id_2" {
  description = "Second public subnet ID for the EKS Cluster"
  type        = string
}

variable "private_subnet_id_1" {
  description = "First private subnet ID for the EKS Cluster"
  type        = string
}

variable "private_subnet_id_2" {
  description = "Second private subnet ID for the EKS Cluster"
  type        = string
}

