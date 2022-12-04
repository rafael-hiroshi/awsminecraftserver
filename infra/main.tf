terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.0"
    }
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

resource "aws_instance" "minecraft_server" {
  ami                  = var.lookup_ami ? data.aws_ami.minecraft_ami.id : var.amazon_linux_ami
  instance_type        = "t3.medium"
  hibernation          = true
  iam_instance_profile = module.iam_sr.ec2_instance_profile
  security_groups      = [aws_security_group.allow_game_traffic.name]
  user_data            = var.lookup_ami ? null : file("${path.module}/../scripts/user_data.sh")

  root_block_device {
    delete_on_termination = true
    encrypted             = true
    iops                  = 3000
    throughput            = 125
    kms_key_id            = var.kms_key_arn
    volume_size           = 10
    volume_type           = "gp3"
  }

  tags = {
    Name = "Minecraft Server"
    IaC  = "Terraform"
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
