##################################### API

resource "aws_apigatewayv2_api" "ApiGateway" {
  name          = var.api_name
  protocol_type = var.protocol_type
}

##################################### AUTHORIZER

resource "aws_apigatewayv2_authorizer" "jwt_authorizer" {
  depends_on      = [aws_apigatewayv2_api.ApiGateway]
  api_id          = aws_apigatewayv2_api.ApiGateway.id
  name            = "jwt_authorizer"
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
  subnet_ids         = var.private_subnets_ids
}

resource "aws_apigatewayv2_integration" "lambda_integration" {
  depends_on             = [aws_apigatewayv2_api.ApiGateway]
  api_id                 = aws_apigatewayv2_api.ApiGateway.id
  integration_type       = "AWS_PROXY"
  integration_method     = "POST"
  integration_uri        = var.lambda_arn
  payload_format_version = "2.0"
}

##################################### INTEGRATION ORDER

resource "aws_apigatewayv2_integration" "load_balancer_integration_order" {
  api_id             = aws_apigatewayv2_api.ApiGateway.id
  integration_type   = "HTTP_PROXY"
  integration_uri    = "${var.integration_uri_lb}/v${var.api_version}/order"
  connection_type    = "INTERNET"
  integration_method = "ANY"
}

resource "aws_apigatewayv2_integration" "load_balancer_integration_order_getbyid" {
  api_id             = aws_apigatewayv2_api.ApiGateway.id
  integration_type   = "HTTP_PROXY"
  integration_uri    = "${var.integration_uri_lb}/v${var.api_version}/order/{id}"
  connection_type    = "INTERNET"
  integration_method = "ANY"
}

resource "aws_apigatewayv2_integration" "load_balancer_integration_order_getbystatus" {
  api_id             = aws_apigatewayv2_api.ApiGateway.id
  integration_type   = "HTTP_PROXY"
  integration_uri    = "${var.integration_uri_lb}/v${var.api_version}/order/filterByStatus/{id}"
  connection_type    = "INTERNET"
  integration_method = "ANY"
}

resource "aws_apigatewayv2_integration" "load_balancer_integration_order_getpendingorder" {
  api_id             = aws_apigatewayv2_api.ApiGateway.id
  integration_type   = "HTTP_PROXY"
  integration_uri    = "${var.integration_uri_lb}/v${var.api_version}/order/getPendingOrders"
  connection_type    = "INTERNET"
  integration_method = "ANY"
}

resource "aws_apigatewayv2_integration" "load_balancer_integration_order_getpaymentstatus" {
  api_id             = aws_apigatewayv2_api.ApiGateway.id
  integration_type   = "HTTP_PROXY"
  integration_uri    = "${var.integration_uri_lb}/v${var.api_version}/order/paymentStatus/{id}"
  connection_type    = "INTERNET"
  integration_method = "ANY"
}

resource "aws_apigatewayv2_integration" "load_balancer_integration_order_receivepayment" {
  api_id             = aws_apigatewayv2_api.ApiGateway.id
  integration_type   = "HTTP_PROXY"
  integration_uri    = "${var.integration_uri_lb}/v${var.api_version}/order/payment/{id}"
  connection_type    = "INTERNET"
  integration_method = "ANY"
}

##################################### ROUTES ORDER

resource "aws_apigatewayv2_route" "load_balancer_route_order_" {
  depends_on         = [aws_apigatewayv2_integration.load_balancer_integration_order]
  api_id             = aws_apigatewayv2_api.ApiGateway.id
  route_key          = "ANY /v${var.api_version}/order"
  target             = "integrations/${aws_apigatewayv2_integration.load_balancer_integration_order.id}"
  authorizer_id      = aws_apigatewayv2_authorizer.jwt_authorizer.id
  authorization_type = "JWT"
}

resource "aws_apigatewayv2_route" "load_balancer_route_order_getbyid" {
  depends_on         = [aws_apigatewayv2_integration.load_balancer_integration_order_getbyid]
  api_id             = aws_apigatewayv2_api.ApiGateway.id
  route_key          = "ANY /v${var.api_version}/order/{id}"
  target             = "integrations/${aws_apigatewayv2_integration.load_balancer_integration_order_getbyid.id}"
  authorizer_id      = aws_apigatewayv2_authorizer.jwt_authorizer.id
  authorization_type = "JWT"
}

resource "aws_apigatewayv2_route" "load_balancer_route_order_getbystatus" {
  depends_on         = [aws_apigatewayv2_integration.load_balancer_integration_order_getbystatus]
  api_id             = aws_apigatewayv2_api.ApiGateway.id
  route_key          = "ANY /v${var.api_version}/order/filterByStatus/{id}"
  target             = "integrations/${aws_apigatewayv2_integration.load_balancer_integration_order_getbystatus.id}"
  authorizer_id      = aws_apigatewayv2_authorizer.jwt_authorizer.id
  authorization_type = "JWT"
}

resource "aws_apigatewayv2_route" "load_balancer_route_order_getpendingorder" {
  depends_on         = [aws_apigatewayv2_integration.load_balancer_integration_order_getpendingorder]
  api_id             = aws_apigatewayv2_api.ApiGateway.id
  route_key          = "ANY /v${var.api_version}/order/getPendingOrders"
  target             = "integrations/${aws_apigatewayv2_integration.load_balancer_integration_order_getpendingorder.id}"
  authorizer_id      = aws_apigatewayv2_authorizer.jwt_authorizer.id
  authorization_type = "JWT"
}

resource "aws_apigatewayv2_route" "load_balancer_route_order_getpaymentstatus" {
  depends_on         = [aws_apigatewayv2_integration.load_balancer_integration_order_getpaymentstatus]
  api_id             = aws_apigatewayv2_api.ApiGateway.id
  route_key          = "ANY /v${var.api_version}/order/paymentStatus/{id}"
  target             = "integrations/${aws_apigatewayv2_integration.load_balancer_integration_order_getpaymentstatus.id}"
  authorizer_id      = aws_apigatewayv2_authorizer.jwt_authorizer.id
  authorization_type = "JWT"
}

resource "aws_apigatewayv2_route" "load_balancer_route_order_receivepayment" {
  depends_on         = [aws_apigatewayv2_integration.load_balancer_integration_order_receivepayment]
  api_id             = aws_apigatewayv2_api.ApiGateway.id
  route_key          = "ANY /v${var.api_version}/order/payment/{id}"
  target             = "integrations/${aws_apigatewayv2_integration.load_balancer_integration_order_receivepayment.id}"
  authorizer_id      = aws_apigatewayv2_authorizer.jwt_authorizer.id
  authorization_type = "JWT"
}


##################################### INTEGRATION PRODUCT

resource "aws_apigatewayv2_integration" "load_balancer_integration_product_post" {
  api_id             = aws_apigatewayv2_api.ApiGateway.id
  integration_type   = "HTTP_PROXY"
  integration_uri    = "${var.integration_uri_lb}/v${var.api_version}/product"
  connection_type    = "INTERNET"
  integration_method = "ANY"
}

resource "aws_apigatewayv2_integration" "load_balancer_integration_product_get" {
  api_id             = aws_apigatewayv2_api.ApiGateway.id
  integration_type   = "HTTP_PROXY"
  integration_uri    = "${var.integration_uri_lb}/v${var.api_version}/product/category/{id}"
  connection_type    = "INTERNET"
  integration_method = "ANY"
}

resource "aws_apigatewayv2_integration" "load_balancer_integration_product_delete" {
  api_id             = aws_apigatewayv2_api.ApiGateway.id
  integration_type   = "HTTP_PROXY"
  integration_uri    = "${var.integration_uri_lb}/v${var.api_version}/product/{id}"
  connection_type    = "INTERNET"
  integration_method = "ANY"
}

##################################### ROUTES PRODUCT

resource "aws_apigatewayv2_route" "load_balancer_route_product_post" {
  depends_on         = [aws_apigatewayv2_integration.load_balancer_integration_product_post]
  api_id             = aws_apigatewayv2_api.ApiGateway.id
  route_key          = "ANY /v${var.api_version}/product"
  target             = "integrations/${aws_apigatewayv2_integration.load_balancer_integration_product_post.id}"
  authorizer_id      = aws_apigatewayv2_authorizer.jwt_authorizer.id
  authorization_type = "JWT"
}

resource "aws_apigatewayv2_route" "load_balancer_route_product_GET" {
  depends_on         = [aws_apigatewayv2_integration.load_balancer_integration_product_get]
  api_id             = aws_apigatewayv2_api.ApiGateway.id
  route_key          = "ANY /v${var.api_version}/product/category/{id}"
  target             = "integrations/${aws_apigatewayv2_integration.load_balancer_integration_product_get.id}"
  authorizer_id      = aws_apigatewayv2_authorizer.jwt_authorizer.id
  authorization_type = "JWT"
}

resource "aws_apigatewayv2_route" "load_balancer_route_product_delete" {
  depends_on         = [aws_apigatewayv2_integration.load_balancer_integration_product_delete]
  api_id             = aws_apigatewayv2_api.ApiGateway.id
  route_key          = "ANY /v${var.api_version}/product/{id}"
  target             = "integrations/${aws_apigatewayv2_integration.load_balancer_integration_product_delete.id}"
  authorizer_id      = aws_apigatewayv2_authorizer.jwt_authorizer.id
  authorization_type = "JWT"
}

resource "aws_apigatewayv2_route" "lambda_route" {
  depends_on = [aws_apigatewayv2_api.ApiGateway, aws_apigatewayv2_integration.lambda_integration]
  api_id     = aws_apigatewayv2_api.ApiGateway.id
  route_key  = "ANY /User/{proxy+}"
  target     = "integrations/${aws_apigatewayv2_integration.lambda_integration.id}"
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
