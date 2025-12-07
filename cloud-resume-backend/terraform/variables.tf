variable "aws_region" {
  description = "AWS region for resources"
  type        = string
  default     = "us-east-1"
}

variable "table_name" {
  description = "DynamoDB table name"
  type        = string
  default     = "resume-visitor-count"
}

variable "project_name" {
  description = "Project name for resource tagging"
  type        = string
  default     = "cloud-resume-challenge"
}

variable "lambda_function_name" {
  description = "Name of the Lambda function"
  type        = string
  default     = "visitor-counter-function"
}

variable "lambda_runtime" {
  description = "Lambda runtime version"
  type        = string
  default     = "python3.11"
}

variable "lambda_timeout" {
  description = "Lambda timeout in seconds"
  type        = number
  default     = 10
}

variable "lambda_memory" {
  description = "Lambda memory in MB"
  type        = number
  default     = 128
}