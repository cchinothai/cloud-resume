# ========================================
# DynamoDB Table for Visitor Counter
# ========================================

resource "aws_dynamodb_table" "visitor_counter" {
  name         = var.table_name
  billing_mode = "PAY_PER_REQUEST" # On-demand pricing (no capacity planning needed)
  hash_key     = "visitor_count"   # Partition key

  attribute {
    name = "visitor_count"
    type = "S" # String type
  }

  # Optional: Enable point-in-time recovery for backups
  point_in_time_recovery {
    enabled = true
  }

  # Optional: Enable server-side encryption
  server_side_encryption {
    enabled = true
  }

  tags = {
    Name        = var.table_name
    Project     = var.project_name
    Environment = "production"
  }
}
