data "aws_ebs_default_kms_key" "current" {}

data "aws_kms_key" "current" {
  key_id = data.aws_ebs_default_kms_key.current.key_arn
}

data "aws_s3_bucket" "s3_bucket" {
  bucket = var.s3_bucket_name
}

data "aws_ebs_snapshot_ids" "ebs_volumes" {
  owners = ["self"]

  filter {
    name   = "volume-size"
    values = ["10"]
  }
}

data "aws_subnet" "selected" {
  availability_zone = "sa-east-1b"
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
