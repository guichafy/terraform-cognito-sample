data "archive_file" "lambda_zip" {
  type        = "zip"
  source_dir  = "${path.module}/lambda/app"
  output_path = "${path.module}/lambda-settings-portal.zip"
}


resource "aws_s3_bucket_object" "lambda_function" {
  bucket = "lab-cognito-serverless"
  key    = "v1.0.0/lambda-settings-portal.zip"
  source = data.archive_file.lambda_zip.output_path

  tags = {
    ManagedBy = "Terraform"
  }
}

resource "aws_lambda_function" "lambda-settings" {
  depends_on = [
    aws_s3_bucket_object.lambda_function,
  ]
  function_name = "SettingsPortal"
  s3_bucket     = "lab-cognito-serverless"
  s3_key        = "v1.0.0/lambda-settings-portal.zip"
  handler       = "main.handler"
  runtime       = "nodejs12.x"
  role          = aws_iam_role.lambda_exec.arn
  tags = {
    ManagedBy = "Terraform"
  }
}



resource "aws_iam_role" "lambda_exec" {
  name                = "serverless_example_lambda"
  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "lambda.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF
}

resource "aws_iam_role_policy" "test_policy" {
  name = "policy-lambda-basic"
  role = aws_iam_role.lambda_exec.id

  # Terraform's "jsonencode" function converts a
  # Terraform expression result to valid JSON syntax.
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "lambda:InvokeFunction",
          "logs:CreateLogGroup", 
          "logs:CreateLogStream", 
          "logs:PutLogEvents",
          "ssm:GetParametersByPath"
        ]
        Effect   = "Allow"
        Resource = "*"
      },
    ]
  })
}
