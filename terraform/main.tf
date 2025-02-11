## 📄 terraform/main.tf

variable "vpc_id" {
  description = "The ID of the VPC where the EC2 instance will be deployed"
  type        = string
}

variable "private_subnet_id" {
  description = "The ID of the private subnet where the EC2 instance will run"
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

variable "public_subnet_id" {
  description = "The ID of the public subnet where the Bastion instance will run"
  type        = string
}

variable "mongodb_s3_bucket" {
  description = "The name of the S3 bucket for MongoDB backups"
  type        = string
}

variable "vpc_cidr" {
  description = "The CIDR block of the VPC"
  type        = string
}

module "network" {
  source = "./modules/network"
}

module "ec2-mongodb" {
  source            = "./modules/ec2-mongodb"
  vpc_id            = var.vpc_id
  private_subnet_id = var.private_subnet_id
  public_subnet_id  = var.public_subnet_id
  mongodb_s3_bucket = var.mongodb_s3_bucket
  vpc_cidr          = var.vpc_cidr
  mongodb_admin_user = var.mongodb_admin_user
  mongodb_admin_password = var.mongodb_admin_password
}

output "mongodb_instance_id" {
  value = module.ec2-mongodb.mongodb_instance_id
}

output "bastion_public_ip" {
  value = module.ec2-mongodb.bastion_public_ip
}

output "mongodb_s3_bucket_name" {
  value = module.ec2-mongodb.mongodb_s3_bucket
}

