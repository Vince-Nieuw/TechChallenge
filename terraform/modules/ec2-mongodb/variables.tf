variable "vpc_id" {
  description = "The ID of the VPC where the EC2 instance will be deployed"
  type        = string
}

variable "private_subnet_id" {
  description = "The ID of the private subnet where the EC2 instance will run"
  type        = string
}

