module "users_lambda" {
  source = "./functions/users"
  depends_on = [data.external.app_gem]
}

resource "aws_apigatewayv2_api" "retro_api" {
  name          = "retro-api"
  protocol_type = "HTTP"
}

resource "aws_apigatewayv2_stage" "default" {
  api_id = aws_apigatewayv2_api.retro_api.id
  name   = "$default"
  auto_deploy = true
}

resource "aws_apigatewayv2_integration" "users_integration" {
  api_id           = aws_apigatewayv2_api.retro_api.id
  integration_type = "AWS_PROXY"

  connection_type           = "INTERNET"
  description               = "Users lambda integration"
  integration_method        = "POST"
  integration_uri           = module.users_lambda.lambda.invoke_arn
  request_parameters     = {
    "append:querystring.action" = "$request.path.action"
  }
}

resource "aws_apigatewayv2_route" "users" {
  api_id    = aws_apigatewayv2_api.retro_api.id
  route_key = "POST /users/{action}"

  target = "integrations/${aws_apigatewayv2_integration.users_integration.id}"
}

data "external" "app_gem" {
  program = ["bash", "-c", <<EOT
rake build >&2 && echo "{\"dir\": \"$(pwd)\"}"
EOT
  ]
  working_dir = "${path.module}/retro"
}
