output "api_id" {
  description = "ID of the API Gateway"
  value       = aws_apigatewayv2_api.this.id
}

output "api_endpoint" {
  description = "Endpoint URL of the API Gateway"
  value       = aws_apigatewayv2_api.this.api_endpoint
}

output "api_execution_arn" {
  description = "Execution ARN of the API Gateway"
  value       = aws_apigatewayv2_api.this.execution_arn
}

output "stage_id" {
  description = "ID of the API Gateway stage"
  value       = aws_apigatewayv2_stage.this.id
}

output "stage_invoke_url" {
  description = "Invoke URL of the API Gateway stage"
  value       = aws_apigatewayv2_stage.this.invoke_url
}

output "integration_id" {
  description = "ID of the API Gateway integration"
  value       = aws_apigatewayv2_integration.this.id
}

output "route_id" {
  description = "ID of the API Gateway route"
  value       = aws_apigatewayv2_route.this.id
}

output "authorizer_id" {
  description = "ID of the API Gateway authorizer (if enabled)"
  value       = var.enable_authorizer ? aws_apigatewayv2_authorizer.this[0].id : null
}

output "log_group_name" {
  description = "Name of the CloudWatch log group"
  value       = aws_cloudwatch_log_group.this.name
}

output "log_group_arn" {
  description = "ARN of the CloudWatch log group"
  value       = aws_cloudwatch_log_group.this.arn
}