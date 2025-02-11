variable "vpc_id" {
  description = "The ID of the VPC where the EC2 instance will be deployed"
  type        = string
}

variable "private_subnet_id" {
  description = "The ID of the private subnet where the EC2 instance will run"
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

variable "mongodb_admin_user" {
  description = "MongoDB admin username"
  type        = string
}

variable "mongodb_admin_password" {
  description = "MongoDB admin password"
  type        = string
}
