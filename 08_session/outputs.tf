# Part 1: EKS Microservices Architecture Outputs

output "vpc_id" {
  description = "ID of the VPC"
  value       = module.vpc.vpc_id
}

output "public_subnet_ids" {
  description = "IDs of public subnets"
  value       = module.vpc.public_subnet_ids
}

output "private_subnet_ids" {
  description = "IDs of private subnets"
  value       = module.vpc.private_subnet_ids
}

output "eks_cluster_id" {
  description = "ID of the EKS cluster"
  value       = module.eks_cluster.cluster_id
}

output "eks_cluster_endpoint" {
  description = "Endpoint for EKS cluster"
  value       = module.eks_cluster.cluster_endpoint
}

output "eks_cluster_security_group_id" {
  description = "Security group ID attached to the EKS cluster"
  value       = aws_security_group.eks_cluster.id
}

output "eks_cluster_oidc_issuer_url" {
  description = "The URL on the EKS cluster OIDC Issuer"
  value       = module.eks_cluster.cluster_oidc_issuer_url
}

output "eks_node_group_id" {
  description = "ID of the EKS node group"
  value       = module.eks_node_group.node_group_id
}

output "eks_node_group_arn" {
  description = "ARN of the EKS node group"
  value       = module.eks_node_group.node_group_arn
}

output "eks_node_group_status" {
  description = "Status of the EKS node group"
  value       = module.eks_node_group.node_group_status
}

output "eks_node_role_arn" {
  description = "ARN of the IAM role used by EKS nodes"
  value       = module.eks_node_group.node_role_arn
}

output "route53_private_zone_id" {
  description = "ID of the Route 53 private hosted zone"
  value       = aws_route53_zone.private.zone_id
}

output "route53_private_zone_name" {
  description = "Name of the Route 53 private hosted zone"
  value       = aws_route53_zone.private.name
}

# Part 2: CloudFront and ECS Outputs

output "s3_multimedia_content_bucket" {
  description = "Name of the S3 bucket for multimedia content"
  value       = aws_s3_bucket.multimedia_content.id
}

output "cloudfront_distribution_id" {
  description = "ID of the CloudFront distribution"
  value       = aws_cloudfront_distribution.multimedia.id
}

output "cloudfront_distribution_domain_name" {
  description = "Domain name of the CloudFront distribution"
  value       = aws_cloudfront_distribution.multimedia.domain_name
}

output "configure_kubectl" {
  description = "Command to configure kubectl"
  value       = "aws eks update-kubeconfig --region ${var.aws_region} --name ${module.eks_cluster.cluster_name}"
}