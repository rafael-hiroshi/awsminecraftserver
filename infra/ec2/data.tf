data "aws_ebs_default_kms_key" "current" {}

data "aws_kms_key" "current" {
  key_id = data.aws_ebs_default_kms_key.current.key_arn
}

data "aws_subnet" "selected" {
  cidr_block = "172.31.32.0/20"
}

data "aws_vpc" "default" {
  default = true
}

data "aws_ami" "amazon_linux_arm64" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = [
      "amzn2-ami-kernel-5.10-hvm-2.0.*.1-arm64-gp2"
    ]
  }

  filter {
    name   = "owner-alias"
    values = [
      "amazon",
    ]
  }
}

data "aws_ami" "amazon_linux_x86" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = [
      "amzn2-ami-kernel-5.10-hvm-2.0.*.3-x86_64-gp2"
    ]
  }

  filter {
    name   = "owner-alias"
    values = [
      "amazon",
    ]
  }
}
