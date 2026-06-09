# API Gateway Outputs
output "config_api_endpoint" {
  description = "Endpoint for Configuration API"
  value       = module.config_api.api_endpoint
}

output "inventory_api_endpoint" {
  description = "Endpoint for Inventory API"
  value       = module.inventory_api.api_endpoint
}

output "shopping_api_endpoint" {
  description = "Endpoint for Shopping API"
  value       = module.shopping_api.api_endpoint
}

output "booking_api_endpoint" {
  description = "Endpoint for Booking API"
  value       = module.booking_api.api_endpoint
}

# DynamoDB Outputs
output "dynamodb_config_table_name" {
  description = "Name of the DynamoDB configuration table"
  value       = aws_dynamodb_table.config.name
}

output "dynamodb_geohash_table_name" {
  description = "Name of the DynamoDB geohash table"
  value       = aws_dynamodb_table.geohash.name
}

# Aurora Outputs
output "aurora_cluster_endpoint" {
  description = "Endpoint for Aurora Serverless cluster"
  value       = aws_rds_cluster.inventory.endpoint
}

output "aurora_cluster_reader_endpoint" {
  description = "Reader endpoint for Aurora Serverless cluster"
  value       = aws_rds_cluster.inventory.reader_endpoint
}

# S3 Outputs
output "s3_published_config_bucket" {
  description = "Name of the S3 bucket for published configuration"
  value       = aws_s3_bucket.published_config.id
}

# ElastiCache Outputs
output "elasticache_endpoint" {
  description = "Endpoint for ElastiCache cluster"
  value       = aws_elasticache_cluster.geo_cache.cache_nodes[0].address
}

# Cognito Outputs
output "cognito_user_pool_id" {
  description = "ID of the Cognito user pool"
  value       = aws_cognito_user_pool.hotel_users.id
}

output "cognito_user_pool_client_id" {
  description = "ID of the Cognito user pool client"
  value       = aws_cognito_user_pool_client.hotel_users.id
}

# Kinesis Outputs
output "kinesis_stream_name" {
  description = "Name of the Kinesis stream"
  value       = aws_kinesis_stream.pricing.name
}

# Location Service Outputs
output "location_place_index_name" {
  description = "Name of the Location Service place index"
  value       = aws_location_place_index.destinations.index_name
}

# Fargate Outputs
output "ecs_cluster_name" {
  description = "Name of the ECS cluster"
  value       = aws_ecs_cluster.main.name
}

output "fargate_service_name" {
  description = "Name of the Fargate ECS service"
  value       = aws_ecs_service.geolocation.name
}

output "fargate_security_group_id" {
  description = "ID of the Fargate security group"
  value       = aws_security_group.fargate.id
}

output "fargate_task_definition_family" {
  description = "Family of the Fargate task definition"
  value       = aws_ecs_task_definition.geolocation.family
}