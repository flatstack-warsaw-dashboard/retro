resource "local_file" "js_config" {
  content  = <<EOT
  export const apiPath = "${aws_apigatewayv2_api.retro_api.api_endpoint}";
EOT
  filename = "${path.module}/client/tf.config.js"
}

output "api_gateway" {
  value = {
    "api_url" = aws_apigatewayv2_api.retro_api.api_endpoint
  }
}
