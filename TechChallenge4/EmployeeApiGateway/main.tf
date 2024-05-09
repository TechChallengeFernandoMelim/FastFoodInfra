##################################### API

resource "aws_apigatewayv2_api" "ApiGateway" {
  name          = var.api_name
  protocol_type = var.protocol_type
}

##################################### AUTHORIZER

resource "aws_apigatewayv2_authorizer" "jwt_authorizer" {
  depends_on      = [aws_apigatewayv2_api.ApiGateway]
  api_id          = aws_apigatewayv2_api.ApiGateway.id
  name            = "jwt_authorizer_employees"
  authorizer_type = "JWT"
  identity_sources = [
    "$request.header.Authorization"
  ]
  jwt_configuration {
    audience = [var.cognito_employee_pool_client_id]
    issuer   = "https://cognito-idp.${var.region}.amazonaws.com/${var.cognito_employee_pool_id}"
  }
}

resource "aws_apigatewayv2_authorizer" "jwt_authorizer_users" {
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

resource "aws_apigatewayv2_integration" "lambda_integration_totem" {
  depends_on             = [aws_apigatewayv2_api.ApiGateway]
  api_id                 = aws_apigatewayv2_api.ApiGateway.id
  integration_type       = "AWS_PROXY"
  integration_method     = "POST"
  integration_uri        = var.lambda_arn_fast_food_totem
  payload_format_version = "2.0"
}

resource "aws_apigatewayv2_integration" "lambda_integration_employeemanagement" {
  depends_on             = [aws_apigatewayv2_api.ApiGateway]
  api_id                 = aws_apigatewayv2_api.ApiGateway.id
  integration_type       = "AWS_PROXY"
  integration_method     = "POST"
  integration_uri        = var.lambda_arn_fast_food_employee
  payload_format_version = "2.0"
}

resource "aws_apigatewayv2_integration" "lambda_integration_payment" {
  depends_on             = [aws_apigatewayv2_api.ApiGateway]
  api_id                 = aws_apigatewayv2_api.ApiGateway.id
  integration_type       = "AWS_PROXY"
  integration_method     = "POST"
  integration_uri        = var.lambda_arn_fast_food_payment
  payload_format_version = "2.0"
}

resource "aws_apigatewayv2_integration" "lambda_integration_production" {
  depends_on             = [aws_apigatewayv2_api.ApiGateway]
  api_id                 = aws_apigatewayv2_api.ApiGateway.id
  integration_type       = "AWS_PROXY"
  integration_method     = "POST"
  integration_uri        = var.lambda_arn_fast_food_production
  payload_format_version = "2.0"
}

##################################### ROUTES


######## TOTEM

resource "aws_apigatewayv2_route" "lambda_route_totem_order_getbyid" {
  depends_on         = [aws_apigatewayv2_api.ApiGateway, aws_apigatewayv2_integration.lambda_integration_totem, aws_apigatewayv2_authorizer.jwt_authorizer]
  api_id             = aws_apigatewayv2_api.ApiGateway.id
  route_key          = "GET /v1/Order/{orderId}"
  target             = "integrations/${aws_apigatewayv2_integration.lambda_integration_totem.id}"
  authorizer_id      = aws_apigatewayv2_authorizer.jwt_authorizer.id
  authorization_type = "JWT"
}

resource "aws_apigatewayv2_route" "lambda_route_totem_order_getallorders" {
  depends_on         = [aws_apigatewayv2_api.ApiGateway, aws_apigatewayv2_integration.lambda_integration_totem, aws_apigatewayv2_authorizer.jwt_authorizer]
  api_id             = aws_apigatewayv2_api.ApiGateway.id
  route_key          = "GET /v1/Order/GetAllOrders"
  target             = "integrations/${aws_apigatewayv2_integration.lambda_integration_totem.id}"
  authorizer_id      = aws_apigatewayv2_authorizer.jwt_authorizer.id
  authorization_type = "JWT"
}

resource "aws_apigatewayv2_route" "lambda_route_totem_product" {
  depends_on         = [aws_apigatewayv2_api.ApiGateway, aws_apigatewayv2_integration.lambda_integration_totem, aws_apigatewayv2_authorizer.jwt_authorizer]
  api_id             = aws_apigatewayv2_api.ApiGateway.id
  route_key          = "ANY /v1/Product/{proxy+}"
  target             = "integrations/${aws_apigatewayv2_integration.lambda_integration_totem.id}"
  authorizer_id      = aws_apigatewayv2_authorizer.jwt_authorizer.id
  authorization_type = "JWT"
}


######## EMPLOYEE

resource "aws_apigatewayv2_route" "lambda_route_employee" {
  depends_on = [aws_apigatewayv2_api.ApiGateway, aws_apigatewayv2_integration.lambda_integration_employeemanagement, aws_apigatewayv2_authorizer.jwt_authorizer]
  api_id     = aws_apigatewayv2_api.ApiGateway.id
  route_key  = "ANY /Employee/{proxy+}"
  target     = "integrations/${aws_apigatewayv2_integration.lambda_integration_employeemanagement.id}"
}

######## PAYMENT

resource "aws_apigatewayv2_route" "lambda_route_totem_payment_create" {
  depends_on         = [aws_apigatewayv2_api.ApiGateway, aws_apigatewayv2_integration.lambda_integration_payment, aws_apigatewayv2_authorizer.jwt_authorizer]
  api_id             = aws_apigatewayv2_api.ApiGateway.id
  route_key          = "POST /CreatePayment"
  target             = "integrations/${aws_apigatewayv2_integration.lambda_integration_payment.id}"
  authorizer_id      = aws_apigatewayv2_authorizer.jwt_authorizer_users.id
  authorization_type = "JWT"
}

resource "aws_apigatewayv2_route" "lambda_route_totem_payment_update" {
  depends_on         = [aws_apigatewayv2_api.ApiGateway, aws_apigatewayv2_integration.lambda_integration_payment, aws_apigatewayv2_authorizer.jwt_authorizer]
  api_id             = aws_apigatewayv2_api.ApiGateway.id
  route_key          = "PATCH /UpdatePayment/{in_store_order_id}"
  target             = "integrations/${aws_apigatewayv2_integration.lambda_integration_payment.id}"
  authorizer_id      = aws_apigatewayv2_authorizer.jwt_authorizer_users.id
  authorization_type = "JWT"
}

######## PRODUCTION


resource "aws_apigatewayv2_route" "lambda_route_totem_production_getNextOrder" {
  depends_on         = [aws_apigatewayv2_api.ApiGateway, aws_apigatewayv2_integration.lambda_integration_production, aws_apigatewayv2_authorizer.jwt_authorizer]
  api_id             = aws_apigatewayv2_api.ApiGateway.id
  route_key          = "GET /GetNextOrder"
  target             = "integrations/${aws_apigatewayv2_integration.lambda_integration_production.id}"
  authorizer_id      = aws_apigatewayv2_authorizer.jwt_authorizer.id
  authorization_type = "JWT"
}

resource "aws_apigatewayv2_route" "lambda_route_totem_production_GetAllPendingOrders" {
  depends_on         = [aws_apigatewayv2_api.ApiGateway, aws_apigatewayv2_integration.lambda_integration_production, aws_apigatewayv2_authorizer.jwt_authorizer]
  api_id             = aws_apigatewayv2_api.ApiGateway.id
  route_key          = "GET /GetAllPendingOrders"
  target             = "integrations/${aws_apigatewayv2_integration.lambda_integration_production.id}"
  authorizer_id      = aws_apigatewayv2_authorizer.jwt_authorizer.id
  authorization_type = "JWT"
}

resource "aws_apigatewayv2_route" "lambda_route_totem_production_ChangeStatus" {
  depends_on         = [aws_apigatewayv2_api.ApiGateway, aws_apigatewayv2_integration.lambda_integration_production, aws_apigatewayv2_authorizer.jwt_authorizer]
  api_id             = aws_apigatewayv2_api.ApiGateway.id
  route_key          = "PATCH /ChangeStatus/{in_store_order_id}/{newStatus}"
  target             = "integrations/${aws_apigatewayv2_integration.lambda_integration_production.id}"
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

resource "aws_lambda_permission" "apigateway_invoke_lambda_totem" {
  depends_on    = [aws_apigatewayv2_api.ApiGateway]
  statement_id  = "AllowExecutionFromAPIGateway_Employees"
  action        = "lambda:InvokeFunction"
  function_name = var.lambda_name_fast_food_totem
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_apigatewayv2_api.ApiGateway.execution_arn}/*/*/*/*"
}

resource "aws_lambda_permission" "apigateway_invoke_lambda_employee" {
  depends_on    = [aws_apigatewayv2_api.ApiGateway]
  statement_id  = "AllowExecutionFromAPIGateway"
  action        = "lambda:InvokeFunction"
  function_name = var.lambda_name_fast_food_employee
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_apigatewayv2_api.ApiGateway.execution_arn}/*/*/*/*"
}

resource "aws_lambda_permission" "apigateway_invoke_lambda_payment" {
  depends_on    = [aws_apigatewayv2_api.ApiGateway]
  statement_id  = "AllowExecutionFromAPIGateway"
  action        = "lambda:InvokeFunction"
  function_name = var.lambda_name_fast_food_payment
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_apigatewayv2_api.ApiGateway.execution_arn}/*"
}

resource "aws_lambda_permission" "apigateway_invoke_lambda_production" {
  depends_on    = [aws_apigatewayv2_api.ApiGateway]
  statement_id  = "AllowExecutionFromAPIGateway"
  action        = "lambda:InvokeFunction"
  function_name = var.lambda_name_fast_food_production
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_apigatewayv2_api.ApiGateway.execution_arn}/*"
}
