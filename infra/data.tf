data "aws_s3_bucket" "s3_bucket" {
  bucket = var.s3_bucket_name
}

data "aws_vpc" "default" {
  default = true
}

data "aws_ami" "minecraft_ami" {
  most_recent = true
  owners      = [var.account_id]

  tags = {
    "Version" : "v1.19.2"
  }
}
