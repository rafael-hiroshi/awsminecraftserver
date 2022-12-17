terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.0"
    }
  }

  backend "s3" {
    bucket = "tfstate-758724857051"
    key    = "server/1.19.2"
    region = "sa-east-1"
  }
}

provider "aws" {
  region = "sa-east-1"
}

module "iam_sr" {
  source         = "./iamsr"
  s3_bucket_name = data.aws_s3_bucket.s3_bucket.bucket
}

module "ssm" {
  source = "./ssm"
}

resource "aws_launch_template" "server" {
  name                                 = "MinecraftServerLaunchTemplate"
  disable_api_stop                     = false
  disable_api_termination              = false
  update_default_version               = true
  image_id                             = var.lookup_ami ? data.aws_ami.minecraft_ami.id : data.aws_ami.amazon_linux.id
  instance_initiated_shutdown_behavior = "terminate"
  instance_type                        = "t3.medium"
  key_name                             = "terraform-aws"
  user_data                            = var.lookup_ami ? null : filebase64("${path.module}/../scripts/user_data.sh")

  block_device_mappings {
    device_name = "/dev/xvda"

    ebs {
      delete_on_termination = true
      encrypted             = true
      iops                  = 3000
      throughput            = 125
      kms_key_id            = data.aws_kms_key.current.arn
      volume_size           = 10
      volume_type           = "gp3"
      snapshot_id           = var.lookup_ami ? data.aws_ebs_snapshot_ids.ebs_volumes.ids[0] : null
    }
  }

  iam_instance_profile {
    arn = module.iam_sr.ec2_instance_profile
  }

  metadata_options {
    http_endpoint               = "enabled"
    http_tokens                 = "optional"
    http_put_response_hop_limit = 1
    instance_metadata_tags      = "enabled"
  }

  monitoring {
    enabled = false
  }

  network_interfaces {
    associate_public_ip_address = true
    subnet_id                   = data.aws_subnet.selected.id
    delete_on_termination       = true
    security_groups             = [aws_security_group.allow_game_traffic.id]
  }

  private_dns_name_options {
    hostname_type                     = "resource-name"
    enable_resource_name_dns_a_record = true
  }

  tag_specifications {
    resource_type = "instance"

    tags = {
      Name    = "Minecraft Server from Launch Template"
      IaC     = "Terraform"
      Game    = "Minecraft"
      Version = "1.19.2"
    }
  }
}

resource "aws_security_group" "allow_game_traffic" {
  name        = "Minecraft Server Instance SG"
  description = "Allow default minecraft game inbound traffic"
  vpc_id      = data.aws_vpc.default.id

  ingress {
    from_port        = 25565
    to_port          = 25565
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }
}
