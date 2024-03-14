resource "aws_ecr_repository" "ecr_user" {
  name = var.ecr_user_name

  image_tag_mutability = var.image_mutability
  
  encryption_configuration {
    encryption_type = var.encrypt_type
  }

  image_scanning_configuration {
    scan_on_push = true
  }

  tags = var.tags
}

resource "null_resource" "push_image" {
  depends_on = [aws_ecr_repository.ecr_user]

  provisioner "local-exec" {
    command = "docker pull alpine && docker tag alpine:latest ${aws_ecr_repository.ecr_user.repository_url}:latest && aws ecr get-login-password --region us-east-1 | docker login --username AWS --password-stdin ${aws_ecr_repository.ecr_user.repository_url} && docker push ${aws_ecr_repository.ecr_user.repository_url}:latest"
  }
}

resource "aws_lambda_function" "fast_food_user_management" {
 depends_on = [null_resource.push_image]
 environment {
   variables = {
     AWS_ACCESS_KEY_DYNAMO = var.access_key_id
     AWS_SECRET_KEY_DYNAMO = var.secret_access_key
     AWS_TABLE_NAME_DYNAMO = var.dynamodb_table_name
     LOG_REGION = var.region
     LOG_GROUP = var.log_group_name
     AWS_USER_POOL_ID = var.cognito_user_pool_id
     AWS_CLIENT_ID_COGNITO = var.cognito_user_pool_client_id
     GUEST_EMAIL = var.guest_user_name
     GUEST_IDENTIFICATION = var.guest_user_password
   }
 }
 package_type = "Image"
 memory_size = "128"
 timeout = 60
 architectures = ["x86_64"]
 function_name = "FastFoodUserManagement"
 image_uri = "${aws_ecr_repository.ecr_user.repository_url}:latest"
 role = var.lambda_role
}
