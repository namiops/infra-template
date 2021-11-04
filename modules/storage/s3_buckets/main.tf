terraform {
  backend "s3" {}
  required_version = "~> 1.0.10"
}

resource "aws_s3_bucket" "s3_buckets" {
  count = length(var.bucket_list)

  bucket = "${var.company}-${var.project}-${var.environment}-${var.bucket_list[count.index].name}"
  acl    = var.bucket_list[count.index].acl

  versioning {
    enabled = var.bucket_list[count.index].versioning
  }
  tags = {
    Project     = var.project
    Name        = "${var.company}-${var.project}-${var.environment}-${var.bucket_list[count.index].name}"
    Environment = var.environment
    Component   = var.component
  }
}
