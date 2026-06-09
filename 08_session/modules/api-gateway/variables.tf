variable "api_name" {
  description = "Name of the API Gateway"
  type        = string
}

variable "lambda_function_name" {
  description = "Name of the Lambda function to integrate with"
  type        = string
}

variable "lambda_invoke_arn" {
  description = "Invoke ARN of the Lambda function"
  type        = string
}

variable "protocol_type" {
  description = "API protocol type (HTTP or WEBSOCKET)"
  type        = string
  default     = "HTTP"
}

variable "cors_allow_origins" {
  description = "List of allowed origins for CORS"
  type        = list(string)
  default     = ["*"]
}

variable "cors_allow_methods" {
  description = "List of allowed HTTP methods for CORS"
  type        = list(string)
  default     = ["GET", "POST", "PUT", "DELETE", "OPTIONS"]
}

variable "cors_allow_headers" {
  description = "List of allowed headers for CORS"
  type        = list(string)
  default     = ["*"]
}

variable "stage_name" {
  description = "Name of the API Gateway stage"
  type        = string
  default     = "$default"
}

variable "auto_deploy" {
  description = "Whether to automatically deploy changes"
  type        = bool
  default     = true
}

variable "route_key" {
  description = "Route key for the API Gateway route"
  type        = string
  default     = "ANY /{proxy+}"
}

variable "log_retention_days" {
  description = "CloudWatch log retention in days"
  type        = number
  default     = 7
}

variable "enable_authorizer" {
  description = "Whether to enable JWT authorizer"
  type        = bool
  default     = false
}

variable "authorizer_name" {
  description = "Name of the authorizer"
  type        = string
  default     = "cognito-authorizer"
}

variable "jwt_audience" {
  description = "List of JWT audience values (e.g., Cognito client IDs)"
  type        = list(string)
  default     = []
}

variable "jwt_issuer" {
  description = "JWT issuer URL (e.g., Cognito user pool endpoint)"
  type        = string
  default     = ""
}

variable "tags" {
  description = "Additional tags for the API Gateway resources"
  type        = map(string)
  default     = {}
}