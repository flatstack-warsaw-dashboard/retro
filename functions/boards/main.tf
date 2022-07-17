variable "data_table" {}

resource "aws_iam_role" "lambda_role" {
  name = "boards_lambda_role"
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
  name         = "aws_iam_policy_for_terraform_aws_boards_lambda_role"
  path         = "/"
  description  = "AWS IAM Policy for managing boards lambda role"

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
      },
      {
        "Action": [
          "dynamodb:BatchGetItem",
          "dynamodb:GetItem",
          "dynamodb:Query",
          "dynamodb:Scan",
          "dynamodb:BatchWriteItem",
          "dynamodb:PutItem",
          "dynamodb:UpdateItem"
        ],
        "Resource": var.data_table.arn,
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
  source_dir = data.external.build.result.dir
  output_path = local.dist_path
}

data "external" "build" {
  program = ["bash", "-c", <<EOT
gem install -i vendor ../../../retro/pkg/retro-0.1.0.gem >&2 && echo "{\"dir\": \"$(pwd)\"}"
EOT
  ]
  working_dir = "${path.module}/src"
}

data "aws_ssm_parameter" "jwt_secret" {
  name = "RETRO_JWT_SECRET"
}

resource "aws_lambda_function" "boards_lambda" {
  filename      = local.dist_path
  function_name = "boards_lambda"
  role          = aws_iam_role.lambda_role.arn
  handler       = "func.Retro.route"

  source_code_hash = data.archive_file.source.output_base64sha256
  environment {
    variables = {
      "GEM_PATH" = "./vendor"
      "JWT_SECRET" = data.aws_ssm_parameter.jwt_secret.value
    }
  }

  runtime = "ruby2.7"
  memory_size = 256
  timeout = 16

  depends_on = [aws_iam_role_policy_attachment.attach_iam_policy_to_iam_role]
}

output "lambda" {
  value = aws_lambda_function.boards_lambda
}
