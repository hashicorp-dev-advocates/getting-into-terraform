# AWS Hybrid Architecture - Terraform Configuration

This Terraform configuration implements a hybrid AWS architecture consisting of two independent systems:

1. **EKS Microservices Architecture**: Amazon EKS cluster with microservices in private subnets
2. **Serverless Reservation System**: Microservice-based serverless lodging reservation system

## Architecture Overview

### Part 1: EKS Microservices Architecture

- **VPC**: 10.0.0.0/16 with 2 public and 2 private subnets across 2 AZs
- **EKS Cluster**: Kubernetes cluster with private worker nodes
- **Networking**: Internet Gateway, NAT Gateways, Route Tables
- **Load Balancing**: AWS Load Balancer Controller for ALB/NLB
- **DNS**: Route 53 Private Hosted Zone for internal services

### Part 2: Serverless Reservation System

#### Microservices

1. **Configuration Microservice**: DynamoDB + S3 for configuration management
2. **Inventory Microservice**: Aurora Serverless for inventory data
3. **Shopping Microservice**: DynamoDB + ElastiCache + Location Service
4. **Booking Microservice**: QLDB for immutable booking records
5. **Content Delivery**: S3 + CloudFront for multimedia content

#### Supporting Services

- **API Gateway**: HTTP APIs for each microservice
- **Lambda Functions**: Serverless compute for business logic
- **Cognito**: User authentication for booking API
- **Kinesis**: Streaming for pricing requests
- **Fargate**: Containerized geolocation API

## Prerequisites

- Terraform >= 1.0
- AWS CLI configured with appropriate credentials
- kubectl (for EKS cluster management)

## Variables

Key variables that can be customized:

- `aws_region`: AWS region (default: us-east-1)
- `environment`: Environment name (default: dev)
- `vpc_cidr`: VPC CIDR block (default: 10.0.0.0/16)
- `eks_cluster_name`: Name of EKS cluster
- `eks_node_instance_types`: Instance types for EKS nodes
- `private_hosted_zone_name`: Route 53 private zone name

See `variables.tf` for complete list.

## Usage

### Initialize Terraform

```bash
terraform init
```

### Plan Infrastructure

```bash
terraform plan
```

### Apply Configuration

```bash
terraform apply
```

### Configure kubectl for EKS

After deployment, configure kubectl:

```bash
aws eks update-kubeconfig --region <region> --name <cluster-name>
```

Or use the output command:

```bash
terraform output -raw configure_kubectl | bash
```

### Destroy Infrastructure

```bash
terraform destroy
```

## Outputs

The configuration provides numerous outputs including:

- EKS cluster endpoint and configuration
- API Gateway endpoints for all microservices
- Database endpoints (Aurora, ElastiCache)
- S3 bucket names
- CloudFront distribution domain
- Cognito user pool details

View all outputs:

```bash
terraform output
```

## Security Considerations

- EKS worker nodes deployed in private subnets
- All databases in private subnets with security groups
- S3 buckets have public access blocked
- CloudFront uses Origin Access Control for S3
- API Gateway with Cognito authorizer for booking API
- Encryption at rest enabled for all data stores
- TLS/HTTPS enforced for all API endpoints

## Cost Optimization

- Aurora Serverless v2 scales to 0.5 ACU minimum
- Lambda functions with appropriate memory allocation
- ElastiCache single node for development
- EKS node group with auto-scaling
- S3 lifecycle policies can be added for cost savings

## Notes

- Lambda functions use placeholder code - actual implementation required
- Fargate task uses nginx placeholder - replace with actual geolocation API
- On-premises connectivity components intentionally omitted per requirements
- QLDB deletion protection set to false for easier cleanup

## File Structure

```
.
├── versions.tf              # Provider configuration
├── variables.tf             # Input variables
├── data.tf                  # Data sources
├── vpc.tf                   # VPC and networking
├── security-groups.tf       # Security groups
├── route53.tf               # Route 53 private zone
├── iam-eks.tf               # IAM roles for EKS
├── iam-serverless.tf        # IAM roles for serverless services
├── eks.tf                   # EKS cluster and node group
├── dynamodb.tf              # DynamoDB tables
├── aurora.tf                # Aurora Serverless cluster
├── s3.tf                    # S3 buckets
├── elasticache.tf           # ElastiCache cluster
├── cognito.tf               # Cognito user pool
├── kinesis.tf               # Kinesis stream
├── location.tf              # Location Service
├── lambda.tf                # Lambda functions
├── api-gateway.tf           # API Gateway APIs
├── cloudfront.tf            # CloudFront distribution
├── fargate.tf               # ECS Fargate service
├── outputs.tf               # Output values
└── README.md                # This file
```

## Support

For issues or questions, refer to the ARCHITECTURE.md file for detailed architecture documentation.