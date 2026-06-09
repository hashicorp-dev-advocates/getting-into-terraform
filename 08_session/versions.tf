terraform {
  required_version = "1.15.3"

  cloud {
    organization = "user-cdkc-9f7eed-org"
    workspaces {
      name = "getting-into-terraform"
    }
  }

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.45"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.9"
    }
    tls = {
      source  = "hashicorp/tls"
      version = "~> 4.3"
    }
    archive = {
      source  = "hashicorp/archive"
      version = "~> 2.8"
    }
  }
}

provider "aws" {
  region = var.aws_region

  default_tags {
    tags = {
      Project     = "monolith"
      Purpose     = "getting-into-terraform"
      ManagedBy   = "terraform"
      Environment = var.environment
    }
  }
}
