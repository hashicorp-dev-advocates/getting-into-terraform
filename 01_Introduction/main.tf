

provider "aws" {
  region = "us-east-1"
}

variable "instance_ami_id" {
  type        = string
  description = "Amazon Machine Image™ id"
  default     = "ami-0071174ad8cbb9e17"
  sensitive   = true
}

resource "aws_instance" "web_different_name" {
  ami                         = var.instance_ami_id
  instance_type               = "t2.micro"
  user_data                   = "export hunter2='some_password'"
  user_data_replace_on_change = true

  # tags = {
  #   Name = "learn-terraform"
  # }
}

output "instance_id" {
  value       = aws_instance.web_different_name.id
  description = "id of the AWS EC2 instance"
  sensitive   = true
}





























# data "aws_ami" "ubuntu" {
#   most_recent = true
#   filter {
#     name   = "name"
#     values = ["ubuntu/images/hvm-ssd-gp3/ubuntu-noble-24.04-amd64-server-*"]
#   }
#   owners = ["099720109477"]
# }