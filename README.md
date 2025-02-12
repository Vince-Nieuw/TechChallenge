
#
Build status

[![Terraform CI/CD Pipeline](https://github.com/Vince-Nieuw/TechChallenge/actions/workflows/terraform-ci.yml/badge.svg?branch=main)](https://github.com/Vince-Nieuw/TechChallenge/actions/workflows/terraform-ci.yml)

# Planning

## 🔹 Phase 1: VPC & Networking Setup
Goal: Set up a VPC with one public and one private subnet to serve as the foundation for the infrastructure.
✅ Create a VPC \ 
✅ Create Public and Private Subnets \ 
✅ Set up an Internet Gateway (for the public subnet) \
✅ Set up a NAT Gateway (for private subnet outbound traffic) \ 
✅ Create Route Tables and associate them with the correct subnets \

## 🔹 Phase 2: Database Server (EC2 with MongoDB)
Goal: Deploy an EC2 instance in the private subnet, install MongoDB, and enable authentication and backups to S3. \
✅ Deploy an EC2 instance in the private subnet \ 
✅ Install MongoDB and configure authentication \ 
✅ Allow DB traffic only from the VPC \ 
✅ Configure automated MongoDB backups to an S3 bucket \ 
✅ Attach an IAM Role to the EC2 instance with S3 backup permissions \ 
✅ Set up a security group that allow  SSH from the internet (for admin access) \

## 🔹 Phase 3: S3 Bucket for Backups
Goal: Create an S3 bucket that holds MongoDB backups and make it publicly readable. \ 
❌ Create an S3 bucket \ 
❌ Configure public read access \ 

## 🔹 Phase 4: Web Application Development
Goal: Build and containerize a simple web application that interacts with MongoDB.
❌ Create a simple API/web app (e.g., Python Flask, Node.js, or another framework) \
✅ Add MongoDB authentication using a connection string \
✅ Store the connection string securely (e.g., Kubernetes Secrets) \ 
❌ Ensure that the application writes/reads data from MongoDB \ 
❌ Include a file called "wizexercise.txt" inside the container \ 

## 🔹 Phase 5: Deploy Web App to Kubernetes (EKS)
Goal: Deploy the web application to Amazon EKS (Kubernetes), ensuring it can talk to MongoDB and be accessible from the internet. 
✅ Create an EKS cluster \ 
❌ Deploy the containerized web application \
❌ Allow public access to the web application via a LoadBalancer \
❌ Ensure the web app authenticates to the MongoDB database \ 
❌ Grant Cluster-Admin privileges to the app \

## 🔹 Phase 6: AWS Config & Misconfigurations
Goal: Enable AWS Config to detect misconfigurations and showcase security risks.
✅ Enable AWS Config \ 
✅ Introduce at least one intentional misconfiguration (e.g., S3 bucket without encryption) \
❌ Review AWS Config’s security findings \

## 🔹 Phase 7: CI/CD Automation
Goal: Ensure everything is deployed automatically using Terraform and GitHub Actions.
✅ Create Terraform modules for each component
✅ Configure GitHub Actions to:
    - Deploy VPC, EC2, S3, and EKS using Terraform
    - Build and deploy web application container to EKS
✅ Ensure Terraform state management (e.g., S3 backend for Terraform state)

## Miscalaneous
✅ Reserve a domain
❌ Point domain DNS-entries to loadb-balancer of app



## Time commitment
| Phase | Focus Area                                      | Estimated Effort |
|-------|-----------------------------------------------|------------------|
| 1     | Set up VPC and networking                     | 1 day            |
| 2     | Deploy EC2 MongoDB                            | 1 day            |
| 3     | Configure S3 bucket for backups               | 0.5 days         |
| 4     | Build a simple web application                | 1-2 days         |
| 5     | Deploy the app on Kubernetes (EKS)           | 2 days           |
| 6     | Enable AWS Config & showcase misconfigurations | 0.5 days         |
| 7     | Automate everything with Terraform & GitHub Actions | 1-2 days  |



