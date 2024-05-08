### SUBINDO VPC
data "aws_availability_zones" "available" {
  filter {
    name   = "opt-in-status"
    values = ["opt-in-not-required"]
  }
}

module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "5.0.0"

  name = "vpc-fast-food-totem"
  cidr                 = "10.0.0.0/16"
  azs                  = data.aws_availability_zones.available.names
  public_subnets       = ["10.0.4.0/24", "10.0.5.0/24", "10.0.6.0/24"]
  enable_dns_hostnames = true
  enable_dns_support   = true
}

resource "aws_db_subnet_group" "rds_subnet" {
  name       = "rds-subnet"
  subnet_ids = module.vpc.public_subnets

  tags = {
    Name = "rds-subnet"
  }
}

resource "aws_security_group" "rds_sg" {
  name_prefix = "rds-"

  vpc_id = module.vpc.vpc_id

  ingress {
    from_port   = 1433
    to_port     = 1433
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] # Allow inbound traffic from any IP address.
  }

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]

  }

  ingress {
    from_port   = 0
    to_port     = 65535
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]

  }

  egress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 1433
    to_port     = 1433
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 65535
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]

  }
}

### SUBINDO RDS

resource "aws_db_instance" "rds-mssql" {
  engine                      = "sqlserver-ex"
  engine_version              = "15.00"
  instance_class              = "db.t3.micro"
  identifier                  = "mydb"
  username                    = var.dbuser
  password                    = var.dbpassword

  allocated_storage = 20
  storage_type      = "gp2"

  port = 1433

#   parameter_group_name   = aws_db_parameter_group.pg_rds.name

  vpc_security_group_ids = [aws_security_group.rds_sg.id]
  db_subnet_group_name   = aws_db_subnet_group.rds_subnet.name

  skip_final_snapshot = true
  publicly_accessible = true
}


### ECR

resource "aws_ecr_repository" "fast_food_totem" {
  name                 = var.fast_food_totem_name_ecr
  image_tag_mutability = var.image_mutability

  encryption_configuration {
    encryption_type = var.encrypt_type
  }

  image_scanning_configuration {
    scan_on_push = true
  }

}

resource "null_resource" "push_image" {
  depends_on = [aws_ecr_repository.fast_food_totem]

  provisioner "local-exec" {
    command = "docker pull alpine && docker tag alpine:latest ${aws_ecr_repository.fast_food_totem.repository_url}:latest && aws ecr get-login-password --region us-east-1 | docker login --username AWS --password-stdin ${aws_ecr_repository.fast_food_totem.repository_url} && docker push ${aws_ecr_repository.fast_food_totem.repository_url}:latest"
  }
}

### LAMBDA

resource "aws_lambda_function" "fast_food_totem_management" {
  depends_on = [null_resource.push_image, aws_ecr_repository.fast_food_totem]
  environment {
    variables = {
      AWS_ACCESS_KEY_DYNAMO = var.access_key_id
      AWS_SECRET_KEY_DYNAMO = var.secret_access_key
      AWS_SQS_LOG           = var.SqsLogQueueUrl
      AWS_SQS_GROUP_ID_LOG  = var.SqsLogQueueGroupId
      SqlServerConnection   = "Server=${split(":", aws_db_instance.rds-mssql.endpoint)[0]},${aws_db_instance.rds-mssql.port};Database=FastFoodTotem;User Id=${var.dbuser};Password=${var.dbpassword};MultipleActiveResultSets=true;TrustServerCertificate=true;"
      PaymentServiceUrl     = ""
    }
  }
  package_type  = "Image"
  memory_size   = "500"
  timeout       = 60
  architectures = ["x86_64"]
  function_name = "FastFoodTotem"
  image_uri     = "${aws_ecr_repository.fast_food_totem.repository_url}:latest"
  role          = var.lambda_role
}

output "security_group_id" {
  value = aws_security_group.rds_sg.id
}

output "public_subnets_ids" {
  value = module.vpc.public_subnets
}

output "lambda_arn_fast_food_totem" {
  value = aws_lambda_function.fast_food_totem_management.invoke_arn
}

output "lambda_name_fast_food_totem" {
  value = aws_lambda_function.fast_food_totem_management.function_name
}