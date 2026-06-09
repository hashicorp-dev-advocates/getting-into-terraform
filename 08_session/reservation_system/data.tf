data "aws_availability_zones" "available" {
  state = "available"
}

data "aws_caller_identity" "current" {}

data "aws_partition" "current" {}

# Reference VPC module from root directory
data "terraform_remote_state" "vpc" {
  backend = "remote"

  config = {
    organization = "user-cdkc-9f7eed-org"
    workspaces = {
      name = "08_session_base_infrastructure"
    }
  }
}