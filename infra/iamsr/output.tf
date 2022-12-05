output "ec2_instance_profile" {
  value = aws_iam_instance_profile.ec2_profile.arn
}

output "ec2_service_role" {
  value = aws_iam_role.ec2_service_role.arn
}

output "s3_bucket_policy" {
  value = aws_iam_policy.s3_bucket.arn
}

output "kms_policy" {
  value = aws_iam_policy.kms_policy.arn
}
