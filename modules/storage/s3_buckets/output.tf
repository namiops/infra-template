output "private_s3_bucket_id" {
  value = "${aws_s3_bucket.s3_buckets.*.bucket}"
}

output "private_s3_bucket_region" {
  value = "${aws_s3_bucket.s3_buckets.*.region}"
}

output "private_s3_bucket_arn" {
  value = "${aws_s3_bucket.s3_buckets.*.arn}"
}

output "private_s3_bucket_bucket_domain_name" {
  value = "${aws_s3_bucket.s3_buckets.*.bucket_domain_name}"
}

output "private_s3_bucket_regional_domain_name" {
  value = "${aws_s3_bucket.s3_buckets.*.bucket_regional_domain_name}"
}

output "private_s3_bucket_hosted_zone_id" {
  value = "${aws_s3_bucket.s3_buckets.*.hosted_zone_id}"
}