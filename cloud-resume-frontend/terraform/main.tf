# ============================
# RESOURCES
# ============================

# Reference existing ACM certificate
data "aws_acm_certificate" "existing_cert" {
  provider    = aws.us_east_1
  domain      = var.domain_name
  statuses    = ["ISSUED"]
  most_recent = true
}

# S3 Bucket
resource "aws_s3_bucket" "resume_bucket" {
  bucket = var.bucket_name

  tags = {
    Name    = var.bucket_name
    Project = var.project_name
  }
}

# Block public access (keep bucket as private)
resource "aws_s3_bucket_public_access_block" "resume_bucket_pab" {
  bucket = aws_s3_bucket.resume_bucket.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# CloudFront Origin Access Control 
resource "aws_cloudfront_origin_access_control" "resume_oac" {
  name                              = "${var.project_name}-oac"
  description                       = "OAC for cloudfront to s3"
  origin_access_control_origin_type = "s3"
  signing_behavior                  = "always"
  signing_protocol                  = "sigv4"
}

# CloudFront Distribution
resource "aws_cloudfront_distribution" "resume" {
  enabled             = true
  is_ipv6_enabled     = true
  default_root_object = "index.html"
  aliases             = [var.domain_name]
  comment             = "CloudFront distribution for ${var.domain_name}"

  # S3 Origin Configuration
  origin {
    domain_name              = aws_s3_bucket.resume_bucket.bucket_regional_domain_name
    origin_id                = "S3-${var.bucket_name}"
    origin_access_control_id = aws_cloudfront_origin_access_control.resume_oac.id
  }

  # Default Cache Behavior
  # Default Cache Behavior (using managed cache policy)
  default_cache_behavior {
    allowed_methods        = ["GET", "HEAD", "OPTIONS"]
    cached_methods         = ["GET", "HEAD"]
    target_origin_id       = "S3-${var.bucket_name}"
    viewer_protocol_policy = "redirect-to-https"
    compress               = true

    # Use AWS managed cache policy (recommended for static sites)
    cache_policy_id = "658327ea-f89d-4fab-a63d-7e88639e58f6" # CachingOptimized

    # Use AWS managed origin request policy
    origin_request_policy_id = "88a5eaf4-2fd4-4709-b370-b4c650ea3fcf" # CORS-S3Origin
  }

  # Viewer Certificate (HTTPS)
  viewer_certificate {
    acm_certificate_arn      = data.aws_acm_certificate.existing_cert.arn
    ssl_support_method       = "sni-only"
    minimum_protocol_version = "TLSv1.3_2025"
  }

  # Restrictions
  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  tags = {
    Name    = "${var.project_name}-cloudfront"
    Project = var.project_name
  }

}

# Bucket Policy - Allow cloudfront to get objects from s3 bucket 
resource "aws_s3_bucket_policy" "resume_bucket_policy" {
  bucket = aws_s3_bucket.resume_bucket.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "AllowCloudFrontServicePrincipal"
        Effect = "Allow"
        Principal = {
          Service = "cloudfront.amazonaws.com"
        }
        Action   = "s3:GetObject"
        Resource = "${aws_s3_bucket.resume_bucket.arn}/*"
        Condition = {
          StringEquals = {
            "AWS:SourceArn" = aws_cloudfront_distribution.resume.arn
          }
        }
      }
    ]
  })
}

# ========================================
# Upload Static Files to S3
# ========================================
resource "aws_s3_object" "index_html" {
  bucket       = aws_s3_bucket.resume_bucket.id
  key          = "index.html"
  source       = "index.html"
  source_hash  = filemd5("index.html")
  content_type = "text/html"
}

resource "aws_s3_object" "about_html" {
  bucket       = aws_s3_bucket.resume_bucket.id
  key          = "about.html"
  source       = "about.html"
  etag         = filemd5("about.html")
  content_type = "text/html"
}

resource "aws_s3_object" "style_css" {
  bucket       = aws_s3_bucket.resume_bucket.id
  key          = "style.css"
  source       = "style.css"
  source_hash  = filemd5("style.css")
  content_type = "text/css"
}

resource "aws_s3_object" "script_js" {
  bucket       = aws_s3_bucket.resume_bucket.id
  key          = "script.js"
  source       = "script.js"
  source_hash  = filemd5("script.js")
  content_type = "application/javascript"
}

resource "aws_s3_object" "projects_html" {
  bucket       = aws_s3_bucket.resume_bucket.id
  key          = "projects.html"
  source       = "projects.html"
  etag         = filemd5("projects.html")
  content_type = "text/html"
}

resource "aws_s3_object" "blog_html" {
  bucket       = aws_s3_bucket.resume_bucket.id
  key          = "blog.html"
  source       = "blog.html"
  etag         = filemd5("blog.html")
  content_type = "text/html"
}

# Upload all blog posts dynamically
resource "aws_s3_object" "blog_posts" {
  for_each = fileset("${path.module}/blog", "*.html")

  bucket       = aws_s3_bucket.resume_bucket.id
  key          = "blog/${each.value}"
  source       = "${path.module}/blog/${each.value}"
  etag         = filemd5("${path.module}/blog/${each.value}")
  content_type = "text/html"
}

resource "aws_s3_object" "architecture_diagram" {
  bucket       = aws_s3_bucket.resume_bucket.id
  key          = "cloud-resume-diagram.png"
  source       = "cloud-resume-diagram.png"
  etag         = filemd5("cloud-resume-diagram.png")
  content_type = "image/png"
}

resource "aws_s3_object" "resume_pdf" {
  bucket       = aws_s3_bucket.resume_bucket.id
  key          = "Cody_Chinothai_Resume_2026D.pdf"
  source       = "Cody_Chinothai_Resume_2026D.pdf"
  etag         = filemd5("Cody_Chinothai_Resume_2026D.pdf")
  content_type = "application/pdf"
  
  # # Make this specific file publicly readable
  # acl = "public-read"
}

resource "aws_s3_object" "headshot" {
  bucket       = aws_s3_bucket.resume_bucket.id
  key          = "headshot-prof.jpg"
  source       = "headshot-prof.jpg"
  etag         = filemd5("headshot-prof.jpg")
  content_type = "image/jpg"
}