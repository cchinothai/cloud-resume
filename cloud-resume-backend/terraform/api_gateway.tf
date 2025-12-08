# ========================================
# API Gateway
# ========================================

# create top-level API gateway container 
resource "aws_api_gateway_rest_api" "visitor_api" {
  name        = "${var.project_name}-api"
  description = "API for visitor counter"

  tags = {
    Name    = "${var.project_name}-api"
    Project = var.project_name
  }
}

# create API resource ('/count' path)
resource "aws_api_gateway_resource" "count_resource" {
  rest_api_id = aws_api_gateway_rest_api.visitor_api.id
  parent_id   = aws_api_gateway_rest_api.visitor_api.root_resource_id #parent path is root "/"
  path_part   = "count"
}

# define http method
resource "aws_api_gateway_method" "get_method" {
  rest_api_id   = aws_api_gateway_rest_api.visitor_api.id
  resource_id   = aws_api_gateway_resource.count_resource.id
  http_method   = "GET"
  authorization = "NONE" # public - no authentication req.
}

# define options method for CORS Preflight Requests (determine if server permits a request other than GET or POST)
resource "aws_api_gateway_method" "options_method" {
  rest_api_id   = aws_api_gateway_rest_api.visitor_api.id
  resource_id   = aws_api_gateway_resource.count_resource.id
  authorization = "NONE"
  http_method   = "OPTIONS"
}

# connect to our backend using AWS_PROXY
resource "aws_api_gateway_integration" "lambda_integration" {
  rest_api_id             = aws_api_gateway_rest_api.visitor_api.id
  resource_id             = aws_api_gateway_resource.count_resource.id
  http_method             = aws_api_gateway_method.get_method.http_method
  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = aws_lambda_function.visitor_counter.invoke_arn
}

# tell OPTIONS method to return a mock response
resource "aws_api_gateway_integration" "options_integration" {
  rest_api_id = aws_api_gateway_rest_api.visitor_api.id
  resource_id = aws_api_gateway_resource.count_resource.id
  http_method = aws_api_gateway_method.options_method.http_method
  type        = "MOCK"

  request_templates = {
    "application/json" = jsonencode({
      statusCode = 200
    })
  }
}

# Defines what headers the OPTIONS response will include (only declares what headers will exist - integration response sets actual values)
resource "aws_api_gateway_method_response" "options_200" {
  rest_api_id = aws_api_gateway_rest_api.visitor_api.id
  resource_id = aws_api_gateway_resource.count_resource.id
  http_method = aws_api_gateway_method.options_method.http_method
  status_code = "200"

  response_parameters = {
    "method.response.header.Access-Control-Allow-Headers" = true #what domains can call this API? 
    "method.response.header.Access-Control-Allow-Methods" = true #which HTTP methods allowed? 
    "method.response.header.Access-Control-Allow-Origin"  = true #which request headers allowed? 
  }
}

# sets the actual values of the CORS headers 
resource "aws_api_gateway_integration_response" "options_integration_response" {
  rest_api_id = aws_api_gateway_rest_api.visitor_api.id
  resource_id = aws_api_gateway_resource.count_resource.id
  status_code = aws_api_gateway_method_response.options_200.status_code
  http_method = aws_api_gateway_method.options_method.http_method

  response_parameters = {
    "method.response.header.Access-Control-Allow-Headers" = "'Content-Type,X-Amz-Date,Authorization,X-Api-Key,X-Amz-Security-Token'"
    "method.response.header.Access-Control-Allow-Methods" = "'GET,OPTIONS'"
    "method.response.header.Access-Control-Allow-Origin"  = "'*'"
  }

  #Wait for integration to exist
  depends_on = [aws_api_gateway_integration.options_integration]
}

# ========================================
# Deploy API Gateway
# ========================================
# Deploy API config to make your API accessible ("publish")
resource "aws_api_gateway_deployment" "api_deployment" {
  rest_api_id = aws_api_gateway_rest_api.visitor_api.id

  # Force new deployment when any of these resources change
  triggers = {
    #create hash of resource IDs
    redeployment = sha1(jsonencode([
      aws_api_gateway_resource.count_resource.id,
      aws_api_gateway_method.get_method.id,
      aws_api_gateway_integration.lambda_integration.id,
      aws_api_gateway_method.options_method.id,
      aws_api_gateway_integration.options_integration.id,
    ]))
  }

  lifecycle {
    create_before_destroy = true
  }

  depends_on = [
    aws_api_gateway_method.get_method,
    aws_api_gateway_integration.lambda_integration,
    aws_api_gateway_method.options_method,
    aws_api_gateway_integration.options_integration,
  ]
}

#API Gateway Stage
resource "aws_api_gateway_stage" "prod" {
  deployment_id = aws_api_gateway_deployment.api_deployment.id
  stage_name    = "prod"
  rest_api_id   = aws_api_gateway_rest_api.visitor_api.id

  tags = {
    Name    = "${var.project_name}-prod-stage"
    Project = var.project_name
  }

}
