
output "mongodb_instance_id" {
  value = aws_instance.mongodb.id
}

output "mongodb_s3_bucket_name" {
  value = aws_s3_bucket.mongodb_backup.bucket
}

output "bastion_public_ip" {
  value = aws_instance.bastion.public_ip
}

