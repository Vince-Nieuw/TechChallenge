resource "aws_config_configuration_recorder" "example" {
  name     = "example-recorder"
  role_arn = var.role_arn
}

resource "aws_config_config_rule" "example" {
  name     = "example-rule"
  source {
    owner             = "AWS"
    source_identifier = "S3_BUCKET_PUBLIC_READ_PROHIBITED"
  }
}

variable "role_arn" {
  description = "IAM role ARN for AWS Config"
  type        = string
}

