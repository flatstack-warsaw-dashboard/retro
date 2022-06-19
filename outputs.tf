output "api_gateway" {
  value = {
    "api_url" = aws_apigatewayv2_api.retro_api.api_endpoint
  }
}
