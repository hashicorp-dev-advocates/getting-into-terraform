# CloudFront Origin Access Control
resource "aws_cloudfront_origin_access_control" "multimedia" {
  name                              = "reservation-multimedia-oac"
  description                       = "OAC for multimedia content bucket"
  origin_access_control_origin_type = "s3"
  signing_behavior                  = "always"
  signing_protocol                  = "sigv4"
}

# CloudFront Distribution for Multimedia Content
resource "aws_cloudfront_distribution" "multimedia" {
  enabled             = true
  is_ipv6_enabled     = true
  comment             = "CloudFront distribution for reservation multimedia content"
  default_root_object = "index.html"

  origin {
    domain_name              = aws_s3_bucket.multimedia_content.bucket_regional_domain_name
    origin_id                = "S3-${aws_s3_bucket.multimedia_content.id}"
    origin_access_control_id = aws_cloudfront_origin_access_control.multimedia.id
  }

  default_cache_behavior {
    allowed_methods  = ["GET", "HEAD", "OPTIONS"]
    cached_methods   = ["GET", "HEAD"]
    target_origin_id = "S3-${aws_s3_bucket.multimedia_content.id}"

    forwarded_values {
      query_string = false

      cookies {
        forward = "none"
      }
    }

    viewer_protocol_policy = "redirect-to-https"
    min_ttl                = 0
    default_ttl            = 3600
    max_ttl                = 86400
    compress               = true
  }

  price_class = "PriceClass_100"

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  viewer_certificate {
    cloudfront_default_certificate = true
  }

  tags = {
    Name = "reservation-multimedia-distribution"
  }
}