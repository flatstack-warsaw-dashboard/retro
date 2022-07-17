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

  global_secondary_index {
    name               = "cid_si"
    hash_key           = "cid"
    projection_type    = "KEYS_ONLY"
  }
}

module "users_lambda" {
  source = "./functions/users"
  data_table = aws_dynamodb_table.data
  depends_on = [data.external.app_gem, aws_dynamodb_table.data]
}

module "boards_lambda" {
  source = "./functions/boards"
  data_table = aws_dynamodb_table.data
  depends_on = [data.external.app_gem, aws_dynamodb_table.data]
}

data "external" "app_gem" {
  program = ["bash", "-c", <<EOT
rake build >&2 && echo "{\"dir\": \"$(pwd)\"}"
EOT
  ]
  working_dir = "${path.module}/retro"
}

data "external" "client" {
  program = ["bash", "-c", <<EOT
npm install >&2 && npm run build >&2 && echo "{\"dir\": \"$(pwd)\/public\"}"
EOT
  ]
  working_dir = "${path.module}/client"
  depends_on = [local_file.js_config]
}

resource "aws_apigatewayv2_api" "retro_api" {
  name          = "retro-api"
  protocol_type = "HTTP"
}

locals {
  lambda_resources = {
    "users" = { "module" = module.users_lambda },
    "boards" = { "module" = module.boards_lambda }
  }
}

resource "aws_lambda_permission" "invoke_permission" {
  for_each = local.lambda_resources
  action        = "lambda:InvokeFunction"
  function_name = each.value.module.lambda.arn
  principal     = "apigateway.amazonaws.com"

  source_arn = "${aws_apigatewayv2_api.retro_api.execution_arn}/*/*"
}

resource "aws_apigatewayv2_stage" "default" {
  api_id = aws_apigatewayv2_api.retro_api.id
  name   = "$default"
  auto_deploy = true
}

resource "aws_apigatewayv2_integration" "lambda_integration" {
  for_each = local.lambda_resources
  api_id           = aws_apigatewayv2_api.retro_api.id
  integration_type = "AWS_PROXY"

  connection_type           = "INTERNET"
  description               = "${each.key} lambda integration"
  integration_method        = "POST"
  integration_uri           = each.value.module.lambda.invoke_arn
  request_parameters     = {
    "append:querystring.action" = "$request.path.action"
  }
}

resource "aws_apigatewayv2_route" "lambda_route" {
  for_each = local.lambda_resources
  api_id    = aws_apigatewayv2_api.retro_api.id
  route_key = "POST /${each.key}/{action}"

  target = "integrations/${aws_apigatewayv2_integration.lambda_integration[each.key].id}"
}

locals {
  public_assets = {
    "index.html" = { "source" = "client/public/index.html", "dest" = "client/index.html", "type" = "text/html" },
    "global.css" = { "source" = "client/public/global.css", "dest" = "client/global.css", "type" = "text/css" },
    "favicon.png" = { "source" = "client/public/favicon.png", "dest" = "client/favicon.png", "type" = "image/png" },
    "build/bundle.js" = { "source" = "client/public/build/bundle.js", "dest" = "client/build/bundle.js", "type" = "application/javascript" },
    "build/bundle.css" = { "source" = "client/public/build/bundle.css", "dest" = "client/build/bundle.css", "type" = "text/css" }
  }
}

resource "aws_apigatewayv2_integration" "s3_asset_integration" {
  for_each = local.public_assets
  api_id           = aws_apigatewayv2_api.retro_api.id
  integration_type = "HTTP_PROXY"

  connection_type           = "INTERNET"
  description               = "S3 integration"
  integration_method        = "GET"
  integration_uri           = "https://${aws_s3_bucket.assets.bucket_regional_domain_name}/${each.value.dest}"
}

resource "aws_apigatewayv2_route" "asset" {
  for_each = local.public_assets
  api_id    = aws_apigatewayv2_api.retro_api.id
  route_key = "GET /${each.key}"

  target = "integrations/${aws_apigatewayv2_integration.s3_asset_integration[each.key].id}"
}

resource "aws_apigatewayv2_route" "root" {
  api_id    = aws_apigatewayv2_api.retro_api.id
  route_key = "GET /"
  target = "integrations/${aws_apigatewayv2_integration.s3_asset_integration["index.html"].id}"
}

resource "aws_apigatewayv2_route" "board_show" {
  api_id    = aws_apigatewayv2_api.retro_api.id
  route_key = "GET /boards/{board_id}"
  target = "integrations/${aws_apigatewayv2_integration.board_path_integration.id}"
}

resource "aws_apigatewayv2_integration" "board_path_integration" {
  api_id           = aws_apigatewayv2_api.retro_api.id
  integration_type = "HTTP_PROXY"

  connection_type           = "INTERNET"
  description               = "S3 integration"
  integration_method        = "GET"
  integration_uri           = "https://${aws_s3_bucket.assets.bucket_regional_domain_name}/client/index.html"
  request_parameters        = {
    "append:querystring.board_id" = "$request.path.board_id"
  }
}

resource "aws_s3_bucket" "assets" {
  bucket = "fwd-retro"
  force_destroy = true
}

resource "aws_s3_bucket_acl" "assets_bucket_acl" {
  bucket = aws_s3_bucket.assets.bucket
  acl    = "private"
}

resource "aws_s3_bucket_object" "asset" {
  for_each = local.public_assets

  bucket = aws_s3_bucket.assets.bucket
  key    = each.value.dest
  source = each.value.source
  content_type =  each.value.type
  acl = "public-read"

  etag = filemd5(each.value.source)
  depends_on = [data.external.client]
}
