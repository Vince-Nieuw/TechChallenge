# ===========================
#  Variable Declaration
# ===========================

variable "s3_bucket_name" {
  description = "S3 bucket name for AWS Config logs"
  type        = string
}

# ===========================
#  IAM Role for AWS Config
# ===========================

resource "aws_iam_role" "aws_config_role" {
  name = "AWSConfigRole"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Effect = "Allow",
      Principal = {
        Service = "config.amazonaws.com"
      },
      Action = "sts:AssumeRole"
    }]
  })
}

# Attach Correct AWS Managed Policy for AWS Config
resource "aws_iam_role_policy_attachment" "aws_config_role_attachment" {
  role       = aws_iam_role.aws_config_role.name
  policy_arn = "arn:aws:iam::aws:policy/AWSConfigRole"
}

# ===========================
#  AWS Config Configuration Recorder
# ===========================

resource "aws_config_configuration_recorder" "example" {
  name     = "example-recorder"
  role_arn = aws_iam_role.aws_config_role.arn

  recording_group {
    all_supported                 = true
    include_global_resource_types = true
  }
}

# AWS Config Delivery Channel (Required for Recorder)
resource "aws_config_delivery_channel" "example" {
  name           = "default"
  s3_bucket_name = var.s3_bucket_name  

  depends_on = [aws_config_configuration_recorder.example]
}

# Ensure the AWS Config Recorder is started
resource "aws_config_configuration_recorder_status" "example" {
  name       = aws_config_configuration_recorder.example.name
  is_enabled = true

  depends_on = [
    aws_config_configuration_recorder.example,
    aws_config_delivery_channel.example
  ]
}

# ===========================
#  AWS Config Rule
# ===========================

resource "aws_config_config_rule" "example" {
  name = "example-rule"

  source {
    owner             = "AWS"
    source_identifier = "S3_BUCKET_PUBLIC_READ_PROHIBITED"
  }

  # Ensure AWS Config Rule is only created AFTER the Configuration Recorder is enabled
  depends_on = [aws_config_configuration_recorder_status.example]
}

# ===========================
#  Outputs
# ===========================

output "aws_config_role_arn" {
  value = aws_iam_role.aws_config_role.arn
}

