
#
Build status

[![Terraform CI/CD Pipeline](https://github.com/Vince-Nieuw/TechChallenge/actions/workflows/terraform-ci.yml/badge.svg?branch=main)](https://github.com/Vince-Nieuw/TechChallenge/actions/workflows/terraform-ci.yml)

# Planning

## 🔹 Phase 1: VPC & Networking Setup
Goal: Set up a VPC with one public and one private subnet to serve as the foundation for the infrastructure.
✅ Create a VPC <br>
✅ Create Public and Private Subnets <br>
✅ Set up an Internet Gateway (for the public subnet) <br>
✅ Set up a NAT Gateway (for private subnet outbound traffic) <br>
✅ Create Route Tables and associate them with the correct subnets <br>

## 🔹 Phase 2: Database Server (EC2 with MongoDB)
Goal: Deploy an EC2 instance in the private subnet, install MongoDB, and enable authentication and backups to S3. <br>
✅ Deploy an EC2 instance in the private subnet <br>
✅ Install MongoDB and configure authentication <br>
✅ Allow DB traffic only from the VPC <br>
✅ Configure automated MongoDB backups to an S3 bucket <br>
✅ Attach an IAM Role to the EC2 instance with S3 backup permissions <br>
✅ Set up a security group that allow  SSH from the internet (for admin access) <br>

## 🔹 Phase 3: S3 Bucket for Backups
Goal: Create an S3 bucket that holds MongoDB backups and make it publicly readable. <br> 
❌ Create an S3 bucket <br>
❌ Configure public read access <br>

## 🔹 Phase 4: Web Application Development
Goal: Build and containerize a simple web application that interacts with MongoDB.
❌ Create a simple API/web app (e.g., Python Flask, Node.js, or another framework) <br>
✅ Add MongoDB authentication using a connection string <br>
✅ Store the connection string securely (e.g., Kubernetes Secrets) <br>
❌ Ensure that the application writes/reads data from MongoDB <br>
❌ Include a file called "wizexercise.txt" inside the container <br>

## 🔹 Phase 5: Deploy Web App to Kubernetes (EKS)
Goal: Deploy the web application to Amazon EKS (Kubernetes), ensuring it can talk to MongoDB and be accessible from the internet. <br>
✅ Create an EKS cluster <br>
❌ Deploy the containerized web application <br>
❌ Allow public access to the web application via a LoadBalancer <br>
❌ Ensure the web app authenticates to the MongoDB database <br>
❌ Grant Cluster-Admin privileges to the app <br>

## 🔹 Phase 6: AWS Config & Misconfigurations
Goal: Enable AWS Config to detect misconfigurations and showcase security risks. <br>
✅ Enable AWS Config <br>
✅ Introduce at least one intentional misconfiguration (e.g., S3 bucket without encryption) <br>
❌ Review AWS Config’s security findings <br>

## 🔹 Phase 7: CI/CD Automation
Goal: Ensure everything is deployed automatically using Terraform and GitHub Actions.
✅ Create Terraform modules for each component <br>
✅ Configure GitHub Actions to: <br>
    - Deploy VPC, EC2, S3, and EKS using Terraform <br>
    - Build and deploy web application container to EKS <br>
✅ Ensure Terraform state management (e.g., S3 backend for Terraform state) <br>

## Miscalaneous
✅ Reserve a domain <br>
❌ Point domain DNS-entries to loadb-balancer of app <br>



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



