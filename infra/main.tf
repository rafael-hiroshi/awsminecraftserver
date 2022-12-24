terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.0"
    }
  }

  backend "s3" {
    bucket = "tfstate-758724857051"
    key    = "dev/resources/terraform.tfstate"
    region = "sa-east-1"
  }
}

provider "aws" {
  alias  = "sa-east-1"
  region = "sa-east-1"
}

module "s3" {
  source         = "./s3"
  s3_bucket_name = local.s3_bucket_name
}

module "iam_sr" {
  source         = "./iamsr"
  s3_bucket_name = local.s3_bucket_name
}

module "launch_template" {
  source             = "./ec2"
  providers = {
    aws = aws.sa-east-1
  }
  lookup_ami         = false
  instance_role_name = module.iam_sr.ec2_instance_profile
  s3_bucket_name     = local.s3_bucket_name
  game_version       = "1.19.2"
  instance_type      = "t3.medium"
  min_memory         = "2048M"
  max_memory         = "3584M"
}
