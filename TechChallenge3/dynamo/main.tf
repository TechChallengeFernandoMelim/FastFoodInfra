resource "aws_dynamodb_table" "FastFoodUserManagement" {
  name           = var.dynamo_table_name
  billing_mode   = var.billing_mode
  read_capacity  = var.read_capacity
  write_capacity = var.write_capacity
  hash_key       = "pk"
  range_key      = "sk"

  attribute {
    name = "pk"
    type = "S"
  }

  attribute {
    name = "sk"
    type = "S"
  }
}

output "dynamodb_table_name" {
  value = aws_dynamodb_table.FastFoodUserManagement.name
}
