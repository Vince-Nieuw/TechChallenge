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

# Attach AWS Managed Policy for AWS Config
resource "aws_iam_role_policy_attachment" "aws_config_role_attachment" {
  role       = aws_iam_role.aws_config_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSConfigRole"
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

# Ensure the AWS Config Recorder is started
resource "aws_config_configuration_recorder_status" "example" {
  name       = aws_config_configuration_recorder.example.name
  is_enabled = true

  depends_on = [aws_config_configuration_recorder.example]
}

# ===========================
#  AWS Config Rule
# ===========================

resource "aws_config_config_rule" "example" {
  name = "example-rule"

  source {
    owner             = "AWS"
    source_identifier = "S3_BUCKET_PUBLIC_READ_PROHIBITED

