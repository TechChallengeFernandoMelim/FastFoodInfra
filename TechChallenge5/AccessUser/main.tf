resource "aws_iam_access_key" "fast_food_access_key" {
  user = aws_iam_user.fast_food_user.name
}

resource "aws_iam_user" "fast_food_user" {
  name = "fast_food_user"
  path = "/system/"
}

data "aws_iam_policy_document" "fast_food_user_policy" {
  statement {
    effect    = "Allow"
    actions   = ["*"]
    resources = ["*"]
  }
}

data "aws_iam_policy_document" "instance_assume_role_policy" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }
  }
}

resource "aws_iam_user_policy" "fast_food_user_policy" {
  name   = "fast_food_user_policy"
  user   = aws_iam_user.fast_food_user.name
  policy = data.aws_iam_policy_document.fast_food_user_policy.json
}

resource "aws_iam_policy" "policy" {
  name   = "policy"
  policy = data.aws_iam_policy_document.fast_food_user_policy.json
}

resource "aws_iam_role" "iam_for_lambda" {
  name               = "AdministratorAccess"
  assume_role_policy = data.aws_iam_policy_document.instance_assume_role_policy.json
}

resource "aws_iam_role_policy_attachment" "admin" {
  role       = aws_iam_role.iam_for_lambda.name
  policy_arn = aws_iam_policy.policy.arn
}

output "access_key_id" {
  value = aws_iam_access_key.fast_food_access_key.id
}

output "secret_access_key" {
  value = aws_iam_access_key.fast_food_access_key.secret
}

output "lambda_role" {
  value = aws_iam_role.iam_for_lambda.arn
}
