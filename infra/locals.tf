locals {
  s3_bucket_name = "${var.s3_bucket_prefix}-${data.aws_caller_identity.current.account_id}"
}
