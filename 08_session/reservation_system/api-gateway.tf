# API Gateway for Configuration Microservice
module "config_api" {
  source = "../modules/api-gateway"

  api_name             = "reservation-config-api"
  lambda_function_name = module.lambda_config.function_name
  lambda_invoke_arn    = module.lambda_config.invoke_arn
}

# API Gateway for Inventory Microservice
module "inventory_api" {
  source = "../modules/api-gateway"

  api_name             = "reservation-inventory-api"
  lambda_function_name = module.lambda_inventory.function_name
  lambda_invoke_arn    = module.lambda_inventory.invoke_arn
}

# API Gateway for Shopping Microservice
module "shopping_api" {
  source = "../modules/api-gateway"

  api_name             = "reservation-shopping-api"
  lambda_function_name = module.lambda_shopping.function_name
  lambda_invoke_arn    = module.lambda_shopping.invoke_arn

  # Override CORS methods for shopping API
  cors_allow_methods = ["GET", "POST", "OPTIONS"]
}

# API Gateway for Booking Microservice
module "booking_api" {
  source = "../modules/api-gateway"

  api_name             = "reservation-booking-api"
  lambda_function_name = module.lambda_booking.function_name
  lambda_invoke_arn    = module.lambda_booking.invoke_arn

  # Enable JWT authorizer for booking API
  enable_authorizer = true
  jwt_audience      = [aws_cognito_user_pool_client.hotel_users.id]
  jwt_issuer        = "https://${aws_cognito_user_pool.hotel_users.endpoint}"
}