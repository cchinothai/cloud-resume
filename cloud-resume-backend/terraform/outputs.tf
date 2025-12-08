output "dynamodb_table_name" {
  description = "DynamoDB table name"
  value       = aws_dynamodb_table.visitor_counter.name
}

output "dynamodb_table_arn" {
  description = "DynamoDB table ARN"
  value       = aws_dynamodb_table.visitor_counter.arn
}

output "lambda_function_name" {
  description = "Lambda function name"
  value       = aws_lambda_function.visitor_counter.function_name
}

output "lambda_function_arn" {
  description = "Lambda function ARN"
  value       = aws_lambda_function.visitor_counter.arn
}

output "lambda_invoke_arn" {
  description = "Lambda invoke ARN (for API Gateway)"
  value       = aws_lambda_function.visitor_counter.invoke_arn
}

output "api_gateway_url" {
  description = "API Gateway endpoint URL"
  value       = "${aws_api_gateway_stage.prod.invoke_url}/count"
}

output "api_gateway_id" {
  description = "API Gateway REST API ID"
  value       = aws_api_gateway_rest_api.visitor_api.id
}