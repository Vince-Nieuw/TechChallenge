# ===========================
#  Variables
# ===========================

variable "bucket_name" {
  description = "The name of the S3 bucket for MongoDB backups"
  type        = string
}


# ===========================
#  S3 Bucket for MongoDB Backups
# ===========================
#
# Note - Re-using this bucket for AWS config as well. 
#

resource "aws_s3_bucket" "mongodb_backup" {
  bucket        = var.bucket_name
  force_destroy = true  # Allows the bucket to be deleted with Terraform

  tags = {
    Name = "MongoDB Backup Bucket"
  }
}

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
        Resource = "${aws_s3_bucket.mongodb_backup.arn}/*"
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

# Hope this works, if not --> manually disable bucket access through GUI
resource "aws_s3_bucket_public_access_block" "mongodb_backup_access" {
  bucket                  = aws_s3_bucket.mongodb_backup.id
  block_public_acls       = false
  block_public_policy     = false
  ignore_public_acls      = false
  restrict_public_buckets = false
}

# ===========================
#  Outputs
# ===========================

output "s3_bucket_name" {
  value = aws_s3_bucket.mongodb_backup.id
}

