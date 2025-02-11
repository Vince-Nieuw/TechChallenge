terraform {
  backend "s3" {
    bucket         = "terraform-remote-state-s3-vincenieuw"
    key            = "terraform.tfstate"
    region         = "eu-north-1"
    dynamodb_table = "terraform-locks"
    encrypt        = true
  }
}

provider "aws" {
  region = "eu-north-1"
}

provider "kubernetes" {
  host                   = module.eks.cluster_endpoint
  cluster_ca_certificate = module.eks.cluster_certificate_authority_data
  token                  = data.aws_eks_cluster_auth.cluster.token
}

provider "helm" {
  kubernetes {
    host                   = module.eks.cluster_endpoint
    cluster_ca_certificate = module.eks.cluster_certificate_authority_data
    token                  = data.aws_eks_cluster_auth.cluster.token
  }
}

