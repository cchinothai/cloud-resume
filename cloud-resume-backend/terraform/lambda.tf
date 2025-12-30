
# ========================================
# IAM Role for Lambda + Other Permissions
# ========================================

# Trust policy - allows Lambda service to assume this role
resource "aws_iam_role" "lambda_execution_role" {
  name = "${var.project_name}-lambda-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "lambda.amazonaws.com"
        }
      }
    ]
  })

  tags = {
    Name    = "${var.project_name}-lambda-role"
    Project = var.project_name
  }
}

# Permissions policy - what Lambda can do
resource "aws_iam_role_policy" "lambda_dynamodb_policy" {
  name = "${var.project_name}-lambda-dynamodb-policy"
  role = aws_iam_role.lambda_execution_role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "dynamodb:UpdateItem",
          "dynamodb:GetItem"
        ]
        Resource = aws_dynamodb_table.visitor_counter.arn
      },
      {
        Effect = "Allow"
        Action = [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ]
        Resource = "arn:aws:logs:*:*:*"
      }
    ]
  })
}

# Allow api gateway to invoke lambda
resource "aws_lambda_permission" "allow_api" {
  statement_id  = "allowInvokeFromAPIGatewayAuthorizor"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.visitor_counter.arn
  principal     = "apigateway.amazonaws.com"
}

output "debug_paths" {
  value = {
    root   = path.root
    module = path.module
    cwd    = path.cwd
  }
}


# Zip the Lambda code
data "archive_file" "lambda_zip" {
  type        = "zip"
  source_file = "${path.root}/lambda/handler.py"
  output_path = "lambda_function.zip"
  
}

# ========================================
# Lambda Function
# ========================================

resource "aws_lambda_function" "visitor_counter" {
  filename         = data.archive_file.lambda_zip.output_path
  function_name    = var.lambda_function_name
  role             = aws_iam_role.lambda_execution_role.arn
  handler          = "handler.lambda_handler"
  source_code_hash = data.archive_file.lambda_zip.output_base64sha256
  runtime          = var.lambda_runtime
  timeout          = var.lambda_timeout
  memory_size      = var.lambda_memory

  environment {
    variables = {
      TABLE_NAME = aws_dynamodb_table.visitor_counter.name
    }
  }

  tags = {
    Name    = var.lambda_function_name
    Project = var.project_name
  }
}