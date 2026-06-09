# Import blocks for existing resources
# Run: terraform plan -generate-config-out=generated.tf

# IAM Roles
import {
  to = module.lambda_config.aws_iam_role.lambda
  id = "reservation-config-lambda-role"
}

import {
  to = module.lambda_inventory_update.aws_iam_role.lambda
  id = "reservation-inventory-update-lambda-role"
}

import {
  to = module.lambda_shopping.aws_iam_role.lambda
  id = "reservation-shopping-lambda-role"
}

import {
  to = module.lambda_booking.aws_iam_role.lambda
  id = "reservation-booking-lambda-role"
}

import {
  to = module.lambda_inventory.aws_iam_role.lambda
  id = "reservation-inventory-lambda-role"
}

# CloudWatch Log Groups
import {
  to = module.shopping_api.aws_cloudwatch_log_group.this
  id = "/aws/apigateway/reservation-shopping-api"
}

import {
  to = module.booking_api.aws_cloudwatch_log_group.this
  id = "/aws/apigateway/reservation-booking-api"
}

import {
  to = module.config_api.aws_cloudwatch_log_group.this
  id = "/aws/apigateway/reservation-config-api"
}

import {
  to = module.inventory_api.aws_cloudwatch_log_group.this
  id = "/aws/apigateway/reservation-inventory-api"
}

# Secrets Manager
import {
  to = aws_secretsmanager_secret.aurora_master_password
  id = "arn:aws:secretsmanager:us-east-1:964607248921:secret:reservation-aurora-password-part-2-HdaQ8d"
}

# DynamoDB Tables
import {
  to = aws_dynamodb_table.config
  id = "reservation-config"
}

import {
  to = aws_dynamodb_table.geohash
  id = "reservation-geohash"
}

# ElastiCache
import {
  to = aws_elasticache_parameter_group.redis7
  id = "reservation-redis7-params"
}

# Cognito
import {
  to = aws_cognito_user_pool_domain.hotel_users
  id = "reservation-hotel-users-964607248921"
}

# S3
import {
  to = aws_s3_bucket.published_config
  id = "reservation-published-config-964607248921"
}

# Location Service
import {
  to = aws_location_place_index.destinations
  id = "reservation-destinations"
}

# Kinesis
import {
  to = aws_kinesis_stream.pricing
  id = "reservation-pricing-requests"
}

# RDS
import {
  to = aws_db_subnet_group.aurora
  id = "reservation-aurora-subnet-group"
}