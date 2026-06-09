# Cognito User Pool for Hotel Users
resource "aws_cognito_user_pool" "hotel_users" {
  name = "reservation-hotel-users"

  username_attributes      = ["email"]
  auto_verified_attributes = ["email"]

  password_policy {
    minimum_length    = 8
    require_lowercase = true
    require_numbers   = true
    require_symbols   = true
    require_uppercase = true
  }

  schema {
    name                = "email"
    attribute_data_type = "String"
    required            = true
    mutable             = false

    string_attribute_constraints {
      min_length = 1
      max_length = 256
    }
  }

  tags = {
    Name = "reservation-hotel-users"
  }
}

# Cognito User Pool Client
resource "aws_cognito_user_pool_client" "hotel_users" {
  name         = "reservation-hotel-users-client"
  user_pool_id = aws_cognito_user_pool.hotel_users.id

  generate_secret                      = false
  allowed_oauth_flows_user_pool_client = true
  allowed_oauth_flows                  = ["code", "implicit"]
  allowed_oauth_scopes                 = ["email", "openid", "profile"]
  callback_urls                        = ["https://localhost:3000/callback"]
  logout_urls                          = ["https://localhost:3000/logout"]
  supported_identity_providers         = ["COGNITO"]

  explicit_auth_flows = [
    "ALLOW_USER_PASSWORD_AUTH",
    "ALLOW_REFRESH_TOKEN_AUTH",
    "ALLOW_USER_SRP_AUTH"
  ]
  lifecycle {
    ignore_changes = [generate_secret]
  }
}

# Cognito User Pool Domain
resource "aws_cognito_user_pool_domain" "hotel_users" {
  domain       = "reservation-hotel-users-${data.aws_caller_identity.current.account_id}"
  user_pool_id = aws_cognito_user_pool.hotel_users.id
}

# DynamoDB Table for Configuration
resource "aws_dynamodb_table" "config" {
  name         = "reservation-config"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "ConfigId"
  range_key    = "Version"

  attribute {
    name = "ConfigId"
    type = "S"
  }

  attribute {
    name = "Version"
    type = "N"
  }

  point_in_time_recovery {
    enabled = true
  }

  server_side_encryption {
    enabled = true
  }

  tags = {
    Name = "reservation-config"
  }
}

# DynamoDB Table for Geohash
resource "aws_dynamodb_table" "geohash" {
  name         = "reservation-geohash"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "Geohash"
  range_key    = "PropertyId"

  attribute {
    name = "Geohash"
    type = "S"
  }

  attribute {
    name = "PropertyId"
    type = "S"
  }

  point_in_time_recovery {
    enabled = true
  }

  server_side_encryption {
    enabled = true
  }

  tags = {
    Name = "reservation-geohash"
  }
}

# S3 Bucket for Published Configuration
resource "aws_s3_bucket" "published_config" {
  bucket = "reservation-published-config-${data.aws_caller_identity.current.account_id}"

  tags = {
    Name = "reservation-published-config"
  }
}

resource "aws_s3_bucket_versioning" "published_config" {
  bucket = aws_s3_bucket.published_config.id

  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "published_config" {
  bucket = aws_s3_bucket.published_config.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

resource "aws_s3_bucket_public_access_block" "published_config" {
  bucket = aws_s3_bucket.published_config.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# S3 Event Notification for Configuration Updates
resource "aws_s3_bucket_notification" "published_config" {
  bucket = aws_s3_bucket.published_config.id

  lambda_function {
    lambda_function_arn = module.lambda_inventory_update.function_arn
    events              = ["s3:ObjectCreated:*"]
    filter_prefix       = "config/"
  }

  depends_on = [aws_lambda_permission.allow_s3_invoke_inventory_update]
}

# Security Group for Lambda functions
resource "aws_security_group" "lambda" {
  name        = "reservation-lambda-sg"
  description = "Security group for Lambda functions"
  vpc_id      = data.terraform_remote_state.vpc.outputs.vpc_id

  tags = {
    Name = "reservation-lambda-sg"
  }
}

resource "aws_vpc_security_group_egress_rule" "lambda_egress" {
  security_group_id = aws_security_group.lambda.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1"
}

# Security Group for Aurora Serverless
resource "aws_security_group" "aurora" {
  name        = "reservation-aurora-sg"
  description = "Security group for Aurora Serverless cluster"
  vpc_id      = data.terraform_remote_state.vpc.outputs.vpc_id

  tags = {
    Name = "reservation-aurora-sg"
  }
}

resource "aws_vpc_security_group_ingress_rule" "aurora_lambda" {
  security_group_id            = aws_security_group.aurora.id
  referenced_security_group_id = aws_security_group.lambda.id
  from_port                    = 3306
  to_port                      = 3306
  ip_protocol                  = "tcp"
  description                  = "Allow Lambda access to Aurora"
}

resource "aws_vpc_security_group_egress_rule" "aurora_egress" {
  security_group_id = aws_security_group.aurora.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1"
}

# DB Subnet Group
resource "aws_db_subnet_group" "aurora" {
  name       = "reservation-aurora-subnet-group"
  subnet_ids = data.terraform_remote_state.vpc.outputs.private_subnet_ids

  tags = {
    Name = "reservation-aurora-subnet-group"
  }
}

# Random password for Aurora
resource "random_password" "aurora_master_password" {
  length  = 16
  special = false
  lifecycle {
    ignore_changes = [length, special]
  }
}

# Store password in Secrets Manager
resource "aws_secretsmanager_secret" "aurora_master_password" {
  name                    = "reservation-aurora-password-part-2"
  recovery_window_in_days = 0

  tags = {
    Name = "reservation-aurora-master-password"
  }
}

resource "aws_secretsmanager_secret_version" "aurora_master_password" {
  secret_id     = aws_secretsmanager_secret.aurora_master_password.id
  secret_string = random_password.aurora_master_password.result
}

# Aurora Serverless v2 Cluster
resource "aws_rds_cluster" "inventory" {
  cluster_identifier     = "reservation-inventory"
  engine                 = "aurora-mysql"
  engine_mode            = "provisioned"
  engine_version         = "8.0.mysql_aurora.3.12.0"
  database_name          = var.aurora_database_name
  master_username        = var.aurora_master_username
  master_password        = random_password.aurora_master_password.result
  db_subnet_group_name   = aws_db_subnet_group.aurora.name
  vpc_security_group_ids = [aws_security_group.aurora.id]
  skip_final_snapshot    = true
  enable_http_endpoint   = true
  storage_encrypted      = true

  serverlessv2_scaling_configuration {
    max_capacity = 1.0
    min_capacity = 0.5
  }

  tags = {
    Name = "reservation-inventory"
  }

  lifecycle {
    ignore_changes = [
      enable_global_write_forwarding,
      enable_local_write_forwarding,
      master_username,
      master_password
    ]
  }
}

# Aurora Serverless v2 Instance
resource "aws_rds_cluster_instance" "inventory" {
  cluster_identifier = aws_rds_cluster.inventory.id
  instance_class     = "db.serverless"
  engine             = aws_rds_cluster.inventory.engine
  engine_version     = aws_rds_cluster.inventory.engine_version

  tags = {
    Name = "reservation-inventory-instance"
  }
}

# Kinesis Stream for Pricing Requests
resource "aws_kinesis_stream" "pricing" {
  name             = "reservation-pricing-requests"
  shard_count      = 1
  retention_period = 24

  shard_level_metrics = [
    "IncomingBytes",
    "IncomingRecords",
    "OutgoingBytes",
    "OutgoingRecords",
  ]

  stream_mode_details {
    stream_mode = "PROVISIONED"
  }

  tags = {
    Name = "reservation-pricing-requests"
  }
}

# Security Group for ElastiCache
resource "aws_security_group" "elasticache" {
  name        = "reservation-elasticache-sg"
  description = "Security group for ElastiCache cluster"
  vpc_id      = data.terraform_remote_state.vpc.outputs.vpc_id

  tags = {
    Name = "reservation-elasticache-sg"
  }
}

resource "aws_vpc_security_group_ingress_rule" "elasticache_lambda" {
  security_group_id            = aws_security_group.elasticache.id
  referenced_security_group_id = aws_security_group.lambda.id
  from_port                    = 6379
  to_port                      = 6379
  ip_protocol                  = "tcp"
  description                  = "Allow Lambda access to ElastiCache"
}

resource "aws_vpc_security_group_egress_rule" "elasticache_egress" {
  security_group_id = aws_security_group.elasticache.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1"
}

# ElastiCache Subnet Group
resource "aws_elasticache_subnet_group" "main" {
  name       = "reservation-elasticache-subnet-group"
  subnet_ids = data.terraform_remote_state.vpc.outputs.private_subnet_ids

  tags = {
    Name = "reservation-elasticache-subnet-group"
  }
}

# ElastiCache Parameter Group
resource "aws_elasticache_parameter_group" "redis7" {
  name   = "reservation-redis7-params"
  family = "redis7"

  tags = {
    Name = "reservation-redis7-params"
  }
}

# ElastiCache Redis Cluster
resource "aws_elasticache_cluster" "geo_cache" {
  cluster_id           = "reservation-geo-cache"
  engine               = "redis"
  node_type            = var.elasticache_node_type
  num_cache_nodes      = var.elasticache_num_cache_nodes
  parameter_group_name = aws_elasticache_parameter_group.redis7.name
  engine_version       = "7.1"
  port                 = 6379
  subnet_group_name    = aws_elasticache_subnet_group.main.name
  security_group_ids   = [aws_security_group.elasticache.id]

  tags = {
    Name = "reservation-geo-cache"
  }
}

# Amazon Location Service Place Index
resource "aws_location_place_index" "destinations" {
  index_name  = "reservation-destinations"
  data_source = "Esri"

  data_source_configuration {
    intended_use = "SingleUse"
  }

  tags = {
    Name = "reservation-destinations"
  }
}

# Fargate Task Execution Role
resource "aws_iam_role" "fargate_execution" {
  name = "reservation-fargate-execution-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ecs-tasks.amazonaws.com"
        }
      }
    ]
  })

  tags = {
    Name = "reservation-fargate-execution-role"
  }
}

resource "aws_iam_role_policy_attachment" "fargate_execution" {
  policy_arn = "arn:${data.aws_partition.current.partition}:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
  role       = aws_iam_role.fargate_execution.name
}

# Fargate Task Role
resource "aws_iam_role" "fargate_task" {
  name = "reservation-fargate-task-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ecs-tasks.amazonaws.com"
        }
      }
    ]
  })

  tags = {
    Name = "reservation-fargate-task-role"
  }
}

resource "aws_iam_role_policy" "fargate_task" {
  name = "reservation-fargate-task-policy"
  role = aws_iam_role.fargate_task.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "geo:SearchPlaceIndexForText",
          "geo:SearchPlaceIndexForPosition"
        ]
        Resource = aws_location_place_index.destinations.index_arn
      }
    ]
  })
}

# ECS Cluster for Fargate
resource "aws_ecs_cluster" "main" {
  name = "reservation-cluster"

  setting {
    name  = "containerInsights"
    value = "enabled"
  }

  tags = {
    Name = "reservation-cluster"
  }
}

# CloudWatch Log Group for Fargate
resource "aws_cloudwatch_log_group" "geolocation" {
  name              = "/ecs/reservation-geolocation"
  retention_in_days = 7

  tags = {
    Name = "reservation-geolocation-logs"
  }
}

# ECS Task Definition for Geolocation API
resource "aws_ecs_task_definition" "geolocation" {
  family                   = "reservation-geolocation"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = "256"
  memory                   = "512"
  execution_role_arn       = aws_iam_role.fargate_execution.arn
  task_role_arn            = aws_iam_role.fargate_task.arn

  container_definitions = jsonencode([
    {
      name      = "geolocation-api"
      image     = "public.ecr.aws/docker/library/nginx:latest"
      essential = true

      portMappings = [
        {
          containerPort = 80
          protocol      = "tcp"
        }
      ]

      environment = [
        {
          name  = "LOCATION_PLACE_INDEX"
          value = aws_location_place_index.destinations.index_name
        }
      ]

      logConfiguration = {
        logDriver = "awslogs"
        options = {
          "awslogs-group"         = aws_cloudwatch_log_group.geolocation.name
          "awslogs-region"        = var.aws_region
          "awslogs-stream-prefix" = "ecs"
        }
      }
    }
  ])

  tags = {
    Name = "reservation-geolocation"
  }
}

# Security Group for Fargate Service
resource "aws_security_group" "fargate" {
  name        = "reservation-fargate-sg"
  description = "Security group for Fargate geolocation service"
  vpc_id      = data.terraform_remote_state.vpc.outputs.vpc_id

  tags = {
    Name = "reservation-fargate-sg"
  }
}

resource "aws_vpc_security_group_ingress_rule" "fargate_lambda" {
  security_group_id            = aws_security_group.fargate.id
  referenced_security_group_id = aws_security_group.lambda.id
  from_port                    = 80
  to_port                      = 80
  ip_protocol                  = "tcp"
  description                  = "Allow Lambda access to Fargate"
}

resource "aws_vpc_security_group_egress_rule" "fargate_egress" {
  security_group_id = aws_security_group.fargate.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1"
}

# ECS Service for Geolocation API
resource "aws_ecs_service" "geolocation" {
  name            = "reservation-geolocation"
  cluster         = aws_ecs_cluster.main.id
  task_definition = aws_ecs_task_definition.geolocation.arn
  desired_count   = 1
  launch_type     = "FARGATE"

  network_configuration {
    subnets          = data.terraform_remote_state.vpc.outputs.private_subnet_ids
    security_groups  = [aws_security_group.fargate.id]
    assign_public_ip = false
  }

  tags = {
    Name = "reservation-geolocation"
  }
}