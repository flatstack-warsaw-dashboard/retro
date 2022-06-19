resource "aws_dynamodb_table" "data" {
  name         = "retro-data"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "pid"
  range_key    = "cid"

  attribute {
    name = "pid"
    type = "S"
  }

  attribute {
    name = "cid"
    type = "S"
  }

  server_side_encryption {
    enabled = true
  }

  point_in_time_recovery {
    enabled = true
  }
}

module "users_lambda" {
  source = "./functions/users"
  data_table = aws_dynamodb_table.data
  depends_on = [data.external.app_gem, aws_dynamodb_table.data]
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

locals {
  public_assets = ["index.html", "global.css", "favicon.png", "build/bundle.js", "build/bundle.css"]
}

resource "aws_apigatewayv2_integration" "s3_asset_integration" {
  for_each = toset(local.public_assets)
  api_id           = aws_apigatewayv2_api.retro_api.id
  integration_type = "HTTP_PROXY"

  connection_type           = "INTERNET"
  description               = "S3 integration"
  integration_method        = "GET"
  integration_uri           = "https://${aws_s3_bucket.assets.bucket_regional_domain_name}/client/${each.value}"
}

resource "aws_apigatewayv2_route" "asset" {
  for_each = toset(local.public_assets)
  api_id    = aws_apigatewayv2_api.retro_api.id
  route_key = "GET /${each.value}"

  target = "integrations/${aws_apigatewayv2_integration.s3_asset_integration[each.value].id}"
}

data "external" "app_gem" {
  program = ["bash", "-c", <<EOT
rake build >&2 && echo "{\"dir\": \"$(pwd)\"}"
EOT
  ]
  working_dir = "${path.module}/retro"
}

resource "aws_s3_bucket" "assets" {
  bucket = "fwd-retro"
  force_destroy = true
}

resource "aws_s3_bucket_acl" "assets_bucket_acl" {
  bucket = aws_s3_bucket.assets.bucket
  acl    = "private"
}

resource "aws_s3_bucket_object" "index" {
  bucket = aws_s3_bucket.assets.bucket
  key    = "client/index.html"
  source = "client/public/index.html"
  content_type = "text/html"
  acl = "public-read"

  etag = filemd5("client/public/index.html")
}

resource "aws_s3_bucket_object" "global" {
  bucket = aws_s3_bucket.assets.bucket
  key    = "client/global.css"
  source = "client/public/global.css"
  content_type = "text/css"
  acl = "public-read"

  etag = filemd5("client/public/global.css")
}

resource "aws_s3_bucket_object" "favicon" {
  bucket = aws_s3_bucket.assets.bucket
  key    = "client/favicon.png"
  source = "client/public/favicon.png"
  content_type = "image/png"
  acl = "public-read"

  etag = filemd5("client/public/favicon.png")
}

resource "aws_s3_bucket_object" "bundle_js" {
  bucket = aws_s3_bucket.assets.bucket
  key    = "client/build/bundle.js"
  source = "client/public/build/bundle.js"
  content_type = "application/javascript"
  acl = "public-read"

  etag = filemd5("client/public/build/bundle.js")
}

resource "aws_s3_bucket_object" "bundle_css" {
  bucket = aws_s3_bucket.assets.bucket
  key    = "client/build/bundle.css"
  source = "client/public/build/bundle.css"
  content_type = "text/css"
  acl = "public-read"

  etag = filemd5("client/public/build/bundle.css")
}
