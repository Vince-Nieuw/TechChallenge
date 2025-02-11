# TechChallenge/terraform/modules/ec2-mongodb/outputs.tf

output "mongodb_s3_bucket_name" {
  value = aws_s3_bucket.mongodb_backup.id
}

output "bastion_public_ip" {
  value = aws_instance.bastion.public_ip
}

output "mongodb_instance_id" {
  value = aws_instance.mongodb.id
}
