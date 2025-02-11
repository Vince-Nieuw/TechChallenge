# Provider Configuration (already in providers.tf)

# Networking Module
module "networking" {
  source = "./modules/networking"
}

# S3 Backup Module
module "s3_backup" {
  source      = "./modules/s3_backup"
  bucket_name = "mongodb-backup-bucket-unique-12345"
}

# MongoDB EC2 Module
module "mongodb_ec2" {
  source             = "./modules/mongodb_ec2"
  vpc_id             = module.networking.vpc_id
  private_subnet_id  = module.networking.private_subnet_id
  mongodb_admin_user = var.mongodb_admin_user
  mongodb_admin_password = var.mongodb_admin_password
  security_group_id  = module.networking.mongodb_sg_id
}

# Bastion Host Module
module "bastion" {
  source            = "./modules/bastion"
  vpc_id            = module.networking.vpc_id
  public_subnet_id  = module.networking.public_subnet_id
  security_group_id = module.networking.mongodb_sg_id
}

# EKS Module
module "eks" {
  source            = "./modules/eks"
  vpc_id            = module.networking.vpc_id
  public_subnet_id  = module.networking.public_subnet_id
  private_subnet_id = module.networking.private_subnet_id
}

# AWS Config Module
module "aws_config" {
  source          = "./modules/aws_config"
  s3_bucket_name = module.s3_backup.s3_bucket_name 
}

