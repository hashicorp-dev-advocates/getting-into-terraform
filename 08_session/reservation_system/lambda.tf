# Lambda Function for Configuration Microservice
module "lambda_config" {
  source = "../modules/lambda"

  function_name = "reservation-config"
  handler       = "index.handler"
  runtime       = "python3.12"
  timeout       = 30
  memory_size   = 256
  filename      = "lambda_placeholder.zip"

  environment_variables = {
    CONFIG_TABLE_NAME = aws_dynamodb_table.config.name
    CONFIG_BUCKET     = aws_s3_bucket.published_config.id
  }

  iam_policy_statements = [
    {
      effect = "Allow"
      actions = [
        "dynamodb:PutItem",
        "dynamodb:GetItem",
        "dynamodb:UpdateItem",
        "dynamodb:DeleteItem",
        "dynamodb:Query",
        "dynamodb:Scan"
      ]
      resources = [aws_dynamodb_table.config.arn]
    },
    {
      effect = "Allow"
      actions = [
        "s3:PutObject",
        "s3:GetObject"
      ]
      resources = ["${aws_s3_bucket.published_config.arn}/*"]
    }
  ]

  partition = data.aws_partition.current.partition

  tags = {
    Name = "reservation-config"
  }
}

# Lambda Function for Inventory Backend
module "lambda_inventory" {
  source = "../modules/lambda"

  function_name = "reservation-inventory"
  handler       = "index.handler"
  runtime       = "python3.12"
  timeout       = 30
  memory_size   = 512
  filename      = "lambda_placeholder.zip"

  vpc_config = {
    subnet_ids         = data.terraform_remote_state.vpc.outputs.private_subnet_ids
    security_group_ids = [aws_security_group.lambda.id]
  }

  attach_vpc_policy = true

  environment_variables = {
    AURORA_CLUSTER_ARN = aws_rds_cluster.inventory.arn
    AURORA_SECRET_ARN  = aws_secretsmanager_secret.aurora_master_password.arn
    DATABASE_NAME      = var.aurora_database_name
  }

  iam_policy_statements = [
    {
      effect = "Allow"
      actions = [
        "rds-data:ExecuteStatement",
        "rds-data:BatchExecuteStatement"
      ]
      resources = [aws_rds_cluster.inventory.arn]
    },
    {
      effect = "Allow"
      actions = [
        "s3:GetObject"
      ]
      resources = ["${aws_s3_bucket.published_config.arn}/*"]
    },
    {
      effect = "Allow"
      actions = [
        "secretsmanager:GetSecretValue"
      ]
      resources = [aws_secretsmanager_secret.aurora_master_password.arn]
    }
  ]

  partition = data.aws_partition.current.partition

  tags = {
    Name = "reservation-inventory"
  }
}

# Lambda Function for Inventory Update Job
module "lambda_inventory_update" {
  source = "../modules/lambda"

  function_name = "reservation-inventory-update"
  handler       = "index.handler"
  runtime       = "python3.12"
  timeout       = 300
  memory_size   = 512
  filename      = "lambda_placeholder.zip"

  vpc_config = {
    subnet_ids         = data.terraform_remote_state.vpc.outputs.private_subnet_ids
    security_group_ids = [aws_security_group.lambda.id]
  }

  attach_vpc_policy = true

  environment_variables = {
    AURORA_CLUSTER_ARN = aws_rds_cluster.inventory.arn
    AURORA_SECRET_ARN  = aws_secretsmanager_secret.aurora_master_password.arn
    DATABASE_NAME      = var.aurora_database_name
    CONFIG_BUCKET      = aws_s3_bucket.published_config.id
  }

  iam_policy_statements = [
    {
      effect = "Allow"
      actions = [
        "rds-data:ExecuteStatement",
        "rds-data:BatchExecuteStatement"
      ]
      resources = [aws_rds_cluster.inventory.arn]
    },
    {
      effect = "Allow"
      actions = [
        "s3:GetObject"
      ]
      resources = ["${aws_s3_bucket.published_config.arn}/*"]
    },
    {
      effect = "Allow"
      actions = [
        "secretsmanager:GetSecretValue"
      ]
      resources = [aws_secretsmanager_secret.aurora_master_password.arn]
    }
  ]

  partition = data.aws_partition.current.partition

  tags = {
    Name = "reservation-inventory-update"
  }
}

# Lambda Permission for S3 to Invoke Inventory Update
resource "aws_lambda_permission" "allow_s3_invoke_inventory_update" {
  statement_id  = "AllowS3Invoke"
  action        = "lambda:InvokeFunction"
  function_name = module.lambda_inventory_update.function_name
  principal     = "s3.amazonaws.com"
  source_arn    = aws_s3_bucket.published_config.arn
}

# Lambda Function for Shopping Microservice
module "lambda_shopping" {
  source = "../modules/lambda"

  function_name = "reservation-shopping"
  handler       = "index.handler"
  runtime       = "python3.12"
  timeout       = 30
  memory_size   = 512
  filename      = "lambda_placeholder.zip"

  vpc_config = {
    subnet_ids         = data.terraform_remote_state.vpc.outputs.private_subnet_ids
    security_group_ids = [aws_security_group.lambda.id]
  }

  attach_vpc_policy = true

  environment_variables = {
    GEOHASH_TABLE_NAME   = aws_dynamodb_table.geohash.name
    CONFIG_BUCKET        = aws_s3_bucket.published_config.id
    KINESIS_STREAM_NAME  = aws_kinesis_stream.pricing.name
    ELASTICACHE_ENDPOINT = aws_elasticache_cluster.geo_cache.cache_nodes[0].address
    LOCATION_PLACE_INDEX = aws_location_place_index.destinations.index_name
  }

  iam_policy_statements = [
    {
      effect = "Allow"
      actions = [
        "dynamodb:GetItem",
        "dynamodb:Query"
      ]
      resources = [aws_dynamodb_table.geohash.arn]
    },
    {
      effect = "Allow"
      actions = [
        "s3:GetObject"
      ]
      resources = ["${aws_s3_bucket.published_config.arn}/*"]
    },
    {
      effect = "Allow"
      actions = [
        "kinesis:PutRecord",
        "kinesis:PutRecords"
      ]
      resources = [aws_kinesis_stream.pricing.arn]
    },
    {
      effect = "Allow"
      actions = [
        "geo:SearchPlaceIndexForText",
        "geo:SearchPlaceIndexForPosition"
      ]
      resources = [aws_location_place_index.destinations.index_arn]
    }
  ]

  partition = data.aws_partition.current.partition

  tags = {
    Name = "reservation-shopping"
  }
}

# Lambda Function for Booking Microservice
module "lambda_booking" {
  source = "../modules/lambda"

  function_name = "reservation-booking"
  handler       = "index.handler"
  runtime       = "python3.12"
  timeout       = 30
  memory_size   = 256
  filename      = "lambda_placeholder.zip"

  environment_variables = {
    QLDB_LEDGER_NAME = "PLACEHOLDER"
  }

  iam_policy_statements = [
    {
      effect = "Allow"
      actions = [
        "qldb:SendCommand"
      ]
      resources = ["*"]
    }
  ]

  partition = data.aws_partition.current.partition

  tags = {
    Name = "reservation-booking"
  }
}