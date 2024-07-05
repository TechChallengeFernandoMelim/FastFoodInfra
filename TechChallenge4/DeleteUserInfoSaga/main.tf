### ECR

resource "aws_ecr_repository" "fast_food_delete_user_saga" {
  name                 = "ecr_fast_food_delete_user_saga"
  image_tag_mutability = var.image_mutability

  encryption_configuration {
    encryption_type = var.encrypt_type
  }

  image_scanning_configuration {
    scan_on_push = true
  }

}

resource "null_resource" "push_image" {
  depends_on = [aws_ecr_repository.fast_food_delete_user_saga]

  provisioner "local-exec" {
    command = "docker pull alpine && docker tag alpine:latest ${aws_ecr_repository.fast_food_delete_user_saga.repository_url}:latest && aws ecr get-login-password --region us-east-1 | docker login --username AWS --password-stdin ${aws_ecr_repository.fast_food_delete_user_saga.repository_url} && docker push ${aws_ecr_repository.fast_food_delete_user_saga.repository_url}:latest"
  }
}

### LAMBDA

resource "aws_lambda_function" "fast_food_delete_user_saga" {
  depends_on = [null_resource.push_image, aws_ecr_repository.fast_food_delete_user_saga]
  environment {
    variables = {
      AWS_ACCESS_KEY_DYNAMO = var.access_key_id
      AWS_SECRET_KEY_DYNAMO = var.secret_access_key
      AWS_SQS_LOG           = var.SqsLogQueueUrl
      AWS_SQS_GROUP_ID_LOG  = var.SqsLogQueueGroupId
      USER_API_GATEWAY_URL  = ""
    }
  }
  package_type  = "Image"
  memory_size   = "500"
  timeout       = 60
  architectures = ["x86_64"]
  function_name = "DeleteUserInfoSaga"
  image_uri     = "${aws_ecr_repository.fast_food_delete_user_saga.repository_url}:latest"
  role          = var.lambda_role
}

output "lambda_arn_delete" {
  value = aws_lambda_function.fast_food_delete_user_saga.invoke_arn
}

output "lambda_name_delete" {
  value = aws_lambda_function.fast_food_delete_user_saga.function_name
}

