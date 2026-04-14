terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.0"
    }
  }
  backend "s3" {
    bucket       = "chris-25908601245"
    key          = "terraform.tfstate"
    region       = "us-east-2"
    use_lockfile = true
  }
}

variable "region" {
  default = "us-east-1"
}

data "aws_ami" "some_ubuntu_image" {
  most_recent = true
  owners      = ["amazon"]
  filter {
    name = "name"
    values = [
      "ubuntu/images/hvm-ssd-gp3/ubuntu-noble-24.04-amd64-server-*"
    ]
  }
}
data "aws_ami" "second_ubuntu_image" {
  most_recent = true
  owners      = ["amazon"]
  filter {
    name = "name"
    values = [
      "ubuntu/images/hvm-ssd-gp3/ubuntu-noble-24.04-amd64-server-*"
    ]
  }
}

resource "aws_instance" "web_different_name" {
  ami                         = data.aws_ami.some_ubuntu_image.id
  instance_type               = "t2.micro"
  user_data                   = "export hunter2='some_'"
  user_data_replace_on_change = true
}

resource "aws_instance" "part_two" {
  ami                         = data.aws_ami.second_ubuntu_image.id
  instance_type               = "t2.micro"
  user_data                   = aws_instance.web_different_name.id
  user_data_replace_on_change = true
}

resource "aws_instance" "part_three" {
  ami                         = data.aws_ami.some_ubuntu_image.id
  instance_type               = "t2.micro"
  user_data                   = data.aws_ami.second_ubuntu_image.id
  user_data_replace_on_change = true
}