terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.92"
    }
    http = {
      source  = "hashicorp/http"
      version = "3.5.0"
    }
  }
  required_version = ">= 1.2, < 2.0"
}

provider "aws" {
  alias  = "virginia"
  region = "us-east-1"
}

provider "aws" {
  alias  = "ohio"
  region = "us-east-2"
}


data "aws_ami" "some_ubuntu_image" {
  #   provider    = aws.ohio
  most_recent = true
  owners      = ["amazon"]
  filter {
    name = "name"
    values = [
      "ubuntu/images/hvm-ssd-gp3/ubuntu-noble-24.04-amd64-server-*"
    ]
  }
}

variable "instances" {
  type = map(object({ instance_type = string, instance_name = string }))
  default = {
    instance_0 = {
      instance_type = "t2.micro",
      instance_name = "larry"
    },
    instance_1 = {
      instance_type = "t2.micro",
      instance_name = "moe"
    },
    instance_2 = {
      instance_type = "t2.micro",
      instance_name = "curly"
    }
  }
}
resource "aws_instance" "web_different_name" {
  #   provider = aws.ohio
  # count                       = 3
  for_each                    = var.instances
  ami                         = data.aws_ami.some_ubuntu_image.id
  instance_type               = each.value.instance_type
  user_data                   = "export hunter2='some_password'"
  user_data_replace_on_change = true
  tags                        = { Name = each.value.instance_name, Purpose = "STreaming, i don't know, some other tag" }
}

variable "enabled_web_more_different_name" {
  type    = bool
  default = true
}

variable "block_devices" {
  type    = map(map(string))
  default = {
    device_1 = {
        volume_type = "standard"
        volume_size = 5
    }
    device_2 = {
        volume_type = "standard"
        volume_size = 6
    }
  }
}
resource "aws_instance" "web_more_different_name" {

  count                       = can(aws_instance.web_different_name["instance_1"]) ? 1 : 0
  ami                         = data.aws_ami.some_ubuntu_image.id
  instance_type               = "t2.micro"
  user_data                   = templatefile("userdata.sh", {AMI_ID=data.aws_ami.some_ubuntu_image.id})

  user_data_replace_on_change = true
  tags                        = {}
  dynamic "ebs_block_device" {
    for_each = var.block_devices
    content {
        volume_type = ebs_block_device.value["volume_type"]
        volume_size = ebs_block_device.value["volume_size"]
        device_name = ebs_block_device.key
    }
  }
}



data "aws_region" "current" {}

output "account_id" {
  value = data.aws_region.current.name
}

output "instance_id" {
  value       = [for i in aws_instance.web_different_name : i.id]
  description = "id of the AWS EC2 instance"
}