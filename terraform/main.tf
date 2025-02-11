# This is the main.tf file in the root folder. Should only redirect ot the modules. 
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.16"
    }
  }

  required_version = ">= 1.2.0"
}

module "network" {
  source = "./modules/network"
}

module "ec2-mongodb" {
  source            = "./modules/ec2-mongodb"
  vpc_id            = module.network.vpc_id
  private_subnet_id = module.network.private_subnet_id
  mongodb_s3_bucket = "your-backup-bucket-name" # Ensure this matches your desired S3 bucket
}

output "mongodb_instance_id" {
  value = module.ec2-mongodb.mongodb_instance_id
}

output "mongodb_s3_bucket_name" {
  value = module.ec2-mongodb.mongodb_s3_bucket_name
}
