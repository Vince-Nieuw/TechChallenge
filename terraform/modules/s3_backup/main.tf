# ===========================
#  Create a KMS Key for AWS Config Logs
# ===========================

resource "aws_kms_key" "s3_config_logs" {
  description             = "KMS key for encrypting AWS Config logs"
  enable_key_rotation     = true
}

resource "aws_kms_alias" "s3_config_logs_alias" {
  name          = "alias/s3-config-logs"
  target_key_id = aws_kms_key.s3_config_logs.id
}

# ===========================
#  S3 Bucket for MongoDB Backups & AWS Config Logs
# ===========================

resource "aws_s3_bucket" "mongodb_backup" {
  bucket        = "mongodb-backup-bucket-unique-12345" # //TODO
  force_destroy = true  # Allows the bucket to be deleted with Terraform

  tags = {
    Name = "MongoDB Backup Bucket"
  }
}

# Using KMS key as using IAM policies will be perceived as a hack. 
data "aws_caller_identity" "current" {}

resource "aws_s3_bucket_policy" "mongodb_backup_policy" {
  bucket = aws_s3_bucket.mongodb_backup.id

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Principal = {
          Service = "config.amazonaws.com"
        },
        Action   = "s3:PutObject",
        Resource = "${aws_s3_bucket.mongodb_backup.arn}/AWSLogs/${data.aws_caller_identity.current.account_id}/Config/*",
        Condition = {
          StringEquals = {
            "s3:x-amz-server-side-encryption" = "aws:kms",
            "s3:x-amz-server-side-encryption-aws-kms-key-id" = aws_kms_key.s3_config_logs.arn
          }
        }
      },
      {
        Effect    = "Allow",
        Principal = "*",
        Action    = "s3:GetObject",
        Resource  = "${aws_s3_bucket.mongodb_backup.arn}/*"
      }
    ]
  })
}

resource "aws_s3_bucket_public_access_block" "mongodb_backup_access" {
  bucket                  = aws_s3_bucket.mongodb_backup.id
  block_public_acls       = false
  block_public_policy     = false
  ignore_public_acls      = false
  restrict_public_buckets = false
}

resource "aws_s3_bucket_ownership_controls" "mongodb_backup_ownership" {
  bucket = aws_s3_bucket.mongodb_backup.id

  rule {
    object_ownership = "BucketOwnerPreferred"
  }
}

resource "aws_s3_bucket_acl" "mongodb_backup_acl" {
  bucket = aws_s3_bucket.mongodb_backup.id
  acl    = "private"
}

# ===========================
#  Outputs
# ===========================

output "s3_bucket_name" {
  value = aws_s3_bucket.mongodb_backup.id
}

output "kms_key_arn" {
  value = aws_kms_key.s3_config_logs.arn
}

