terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.92"
      # version = ">= 5.92.1, < 5.93.0"
    }
    http = {
      source = "hashicorp/http"
      version = "3.5.0"
    }
  }
  required_version = ">= 1.2, < 2.0"
}

resource "aws_secretsmanager_secret" "my_ssh_key" {
  name = "my_ssh_key"
}

resource "aws_secretsmanager_secret_version" "my_ssh_key" {
  secret_id = aws_secretsmanager_secret.my_ssh_key.id
  secret_string_wo = var.my_ssh_key
  secret_string_wo_version = 1
}

locals {
  my_first_local_variable = "AppName"
  default_tags = {
    Name = local.my_first_local_variable
    terraform = true
  }
  all_tags = merge(var.additional_tags, local.default_tags, {"SSH_KEY"=ephemeral.aws_secretsmanager_secret_version.value_to_retrieve.secret_string})
}

ephemeral "aws_secretsmanager_secret_version" "value_to_retrieve" {
  secret_id = aws_secretsmanager_secret.my_ssh_key.id
}

variable "my_ssh_key" {
  type = string
  description = "Super secret SSH Key"
  sensitive = true
  ephemeral = true
}

variable "additional_tags" {
  type = map(string)
  description = "Additional tags to add"
  default = {}
}

data "aws_ami" "some_ubuntu_image" {
  most_recent = true
  owners = ["amazon"]
  filter {
    name = "name"
    values = [
      "ubuntu/images/hvm-ssd-gp3/ubuntu-noble-24.04-amd64-server-*"
    ]
  }
}

data "http" "my_ip_adddress" {
  method = "GET"
  request_headers = {
    Accept = "application/json"
    ContentType = "application/json"
  }
  url = "https://ifconfig.me"
}

provider "aws" {
  region = "us-east-1"
}

resource "aws_instance" "web_different_name" {
  ami                         = data.aws_ami.some_ubuntu_image.id
  instance_type               = "t2.micro"
  user_data                   = "export hunter2='some_password'"
  user_data_replace_on_change = true

  tags = local.all_tags
}

output "instance_id" {
  value       = aws_instance.web_different_name.id
  description = "id of the AWS EC2 instance"
  sensitive   = true
}

output "ami_id" {
  value       = data.aws_ami.some_ubuntu_image.id
  description = "id of the Amazon Machine Image (AMI)"
}

output "ip_address" {
  value       = data.http.my_ip_adddress.response_body
  description = "all the secret IPs"
}




























# data "aws_ami" "ubuntu" {
#   most_recent = true
#   filter {
#     name   = "name"
#     values = ["ubuntu/images/hvm-ssd-gp3/ubuntu-noble-24.04-amd64-server-*"]
#   }
#   owners = ["099720109477"]
# }