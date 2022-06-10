resource "aws_dynamodb_table" "users" {
  name         = "users"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "id"

  attribute {
    name = "id"
    type = "S"
  }

  server_side_encryption {
    enabled = true
  }

  point_in_time_recovery {
    enabled = true
  }
}

resource "aws_iam_role" "lambda_role" {
  name = "users_lambda_role"
  assume_role_policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Action" : "sts:AssumeRole",
        "Principal" : {
        "Service" : "lambda.amazonaws.com"
      },
        "Effect" : "Allow",
        "Sid" : ""
      }
    ]
  })
}

resource "aws_iam_policy" "lambda_policy" {
  name         = "aws_iam_policy_for_terraform_aws_users_lambda_role"
  path         = "/"
  description  = "AWS IAM Policy for managing users lambda role"

  policy = jsonencode({
    "Version": "2012-10-17",
    "Statement": [
      {
        "Action": [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ],
        "Resource": "arn:aws:logs:*:*:*",
        "Effect": "Allow"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "attach_iam_policy_to_iam_role" {
  role        = aws_iam_role.lambda_role.name
  policy_arn  = aws_iam_policy.lambda_policy.arn
}

locals {
  dist_path = "${path.module}/dist/lambda.zip"
}

data "archive_file" "source" {
  type = "zip"
  source_dir = "${path.module}/src"
  output_path = local.dist_path
}

resource "aws_lambda_function" "users_lambda" {
  filename      = local.dist_path
  function_name = "users_lambda"
  role          = aws_iam_role.lambda_role.arn
  handler       = "func.Retro.route"

  source_code_hash = data.archive_file.source.output_base64sha256

  runtime = "ruby2.7"

  depends_on = [aws_iam_role_policy_attachment.attach_iam_policy_to_iam_role]
}

output "lambda" {
  value = aws_lambda_function.users_lambda
}
