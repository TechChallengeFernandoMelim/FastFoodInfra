resource "aws_cloudwatch_log_group" "FastFoodUserManagementLogging" {
  name = var.cloudwatch_group_name
}
