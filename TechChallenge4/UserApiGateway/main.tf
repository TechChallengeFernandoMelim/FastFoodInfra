##################################### API

resource "aws_apigatewayv2_api" "ApiGateway" {
  name          = var.api_name
  protocol_type = var.protocol_type
}

##################################### AUTHORIZER

resource "aws_apigatewayv2_authorizer" "jwt_authorizer" {
  depends_on      = [aws_apigatewayv2_api.ApiGateway]
  api_id          = aws_apigatewayv2_api.ApiGateway.id
  name            = "jwt_authorizer_users"
  authorizer_type = "JWT"
  identity_sources = [
    "$request.header.Authorization"
  ]
  jwt_configuration {
    audience = [var.cognito_user_pool_client_id]
    issuer   = "https://cognito-idp.${var.region}.amazonaws.com/${var.cognito_user_pool_id}"
  }
}


##################################### INTEGRATION

resource "aws_apigatewayv2_vpc_link" "vpc_link_api_to_lb" {
  name               = "vpc_link_api_to_lb"
  security_group_ids = [var.security_group_id]
  subnet_ids         = var.public_subnets_ids
}

resource "aws_apigatewayv2_integration" "lambda_integration" {
  depends_on             = [aws_apigatewayv2_api.ApiGateway]
  api_id                 = aws_apigatewayv2_api.ApiGateway.id
  integration_type       = "AWS_PROXY"
  integration_method     = "POST"
  integration_uri        = var.lambda_arn
  payload_format_version = "2.0"
}

resource "aws_apigatewayv2_integration" "lambda_integration_totem" {
  depends_on             = [aws_apigatewayv2_api.ApiGateway]
  api_id                 = aws_apigatewayv2_api.ApiGateway.id
  integration_type       = "AWS_PROXY"
  integration_method     = "POST"
  integration_uri        = var.lambda_arn_fast_food_totem
  payload_format_version = "2.0"
}

##################################### ROUTES

######## USER

resource "aws_apigatewayv2_route" "lambda_route" {
  depends_on = [aws_apigatewayv2_api.ApiGateway, aws_apigatewayv2_integration.lambda_integration, aws_apigatewayv2_authorizer.jwt_authorizer]
  api_id     = aws_apigatewayv2_api.ApiGateway.id
  route_key  = "ANY /User/{proxy+}"
  target     = "integrations/${aws_apigatewayv2_integration.lambda_integration.id}"
}

######## TOTEM

resource "aws_apigatewayv2_route" "lambda_route_totem_product" {
  depends_on         = [aws_apigatewayv2_api.ApiGateway, aws_apigatewayv2_integration.lambda_integration_totem, aws_apigatewayv2_authorizer.jwt_authorizer]
  api_id             = aws_apigatewayv2_api.ApiGateway.id
  route_key          = "GET /v1/Product/category/{type}"
  target             = "integrations/${aws_apigatewayv2_integration.lambda_integration_totem.id}"
  authorizer_id      = aws_apigatewayv2_authorizer.jwt_authorizer.id
  authorization_type = "JWT"
}

resource "aws_apigatewayv2_route" "lambda_route_totem_order" {
  depends_on         = [aws_apigatewayv2_api.ApiGateway, aws_apigatewayv2_integration.lambda_integration_totem, aws_apigatewayv2_authorizer.jwt_authorizer]
  api_id             = aws_apigatewayv2_api.ApiGateway.id
  route_key          = "POST /v1/Order"
  target             = "integrations/${aws_apigatewayv2_integration.lambda_integration_totem.id}"
  authorizer_id      = aws_apigatewayv2_authorizer.jwt_authorizer.id
  authorization_type = "JWT"
}

##################################### STAGE

resource "aws_apigatewayv2_stage" "ApiGatewayStage" {
  depends_on  = [aws_apigatewayv2_api.ApiGateway]
  api_id      = aws_apigatewayv2_api.ApiGateway.id
  name        = "ApiGatewayStage"
  auto_deploy = true
}

##################################### PERMISSIONS

resource "aws_lambda_permission" "apigateway_invoke_lambda" {
  depends_on    = [aws_apigatewayv2_api.ApiGateway]
  statement_id  = "AllowExecutionFromAPIGateway"
  action        = "lambda:InvokeFunction"
  function_name = var.lambda_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_apigatewayv2_api.ApiGateway.execution_arn}/*/*/User/*"
}

resource "aws_lambda_permission" "apigateway_invoke_lambda_totem" {
  depends_on    = [aws_apigatewayv2_api.ApiGateway]
  statement_id  = "AllowExecutionFromAPIGateway"
  action        = "lambda:InvokeFunction"
  function_name = var.lambda_name_fast_food_totem
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_apigatewayv2_api.ApiGateway.execution_arn}/*/*/*/*"
}
