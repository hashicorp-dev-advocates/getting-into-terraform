# Route 53 Private Hosted Zone
resource "aws_route53_zone" "private" {
  name = var.private_hosted_zone_name

  vpc {
    vpc_id = module.vpc.vpc_id
  }

  tags = {
    Name = "private-hosted-zone"
  }
}