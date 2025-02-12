# ===========================
#  Create EKS Cluster
# ===========================

module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "19.12.0"

  cluster_name    = "web-application-cluster"
  cluster_version = "1.27"

  # Control plane must be spread over 2 AZs
  subnet_ids = [var.public_subnet_id_1, var.public_subnet_id_2]
  vpc_id     = var.vpc_id

  eks_managed_node_groups = {
    eks_nodes = {
      desired_capacity = 1  # Keeping cost low
      max_capacity     = 1
      min_capacity     = 1
      instance_types   = ["t3.medium"]
      subnet_ids       = [var.private_subnet_id_1]  # Ensure only 1 node in 1 subnet
    }
  }
}

# ===========================
#  Wait for EKS to Be Ready (No Sleep!)
# ===========================

data "aws_eks_cluster" "eks" {
  name = module.eks.cluster_name
}

data "aws_eks_cluster_auth" "eks" {
  name = module.eks.cluster_name
}

# ===========================
#  AWS Auth ConfigMap
# ===========================

resource "kubernetes_config_map" "aws_auth" {
  depends_on = [module.eks, data.aws_eks_cluster.eks]

  metadata {
    name      = "aws-auth"
    namespace = "kube-system"
  }

  data = {
    mapRoles = jsonencode([
      {
        rolearn  = module.eks.eks_managed_node_groups["eks_nodes"].iam_role_arn
        username = "system:node:{{EC2PrivateDNSName}}"
        groups   = ["system:bootstrappers", "system:nodes"]
      }
    ])
  }
}

# ===========================
#  Outputs
# ===========================

output "cluster_name" {
  value = module.eks.cluster_name
}

output "cluster_endpoint" {
  value = module.eks.cluster_endpoint
}

output "cluster_certificate_authority_data" {
  value = module.eks.cluster_certificate_authority_data
}

output "node_role_arn" {
  value = module.eks.eks_managed_node_groups["eks_nodes"].iam_role_arn
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

