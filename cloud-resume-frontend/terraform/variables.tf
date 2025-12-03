variable "aws_region" {
  description = "AWS region for resources"
  type        = string
  default     = "us-east-1"
}

variable "domain_name" {
  description = "Custom domain name for our resume"
  type        = string
  default     = "cchinothai.com"
}

variable "bucket_name" {
  description = "S3 bucket name for static website"
  type        = string
  default     = "s3-resume-cchinothai"
}

variable "project_name" {
  description = "Project name for resource tagging"
  type        = string
  default     = "cloud-resume-challenge"
}