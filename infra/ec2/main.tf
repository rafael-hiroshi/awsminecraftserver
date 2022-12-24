terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 2.7.0"
    }
  }
}

module "ssm" {
  source = "./../ssm"
}

resource "aws_launch_template" "server" {
  name                                 = "MinecraftVanillaServer"
  disable_api_stop                     = false
  disable_api_termination              = false
  update_default_version               = true
  image_id                             = var.lookup_ami ? data.aws_ami.minecraft_ami.id : data.aws_ami.amazon_linux_x86.id
  instance_initiated_shutdown_behavior = "stop"
  instance_type                        = var.instance_type
  key_name                             = "terraform-aws"
  user_data                            = var.lookup_ami ? null : base64encode(data.template_file.environment.rendered)

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
    arn = var.instance_role_name
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

data "template_file" "environment" {
  template = file("${path.module}/scripts/user_data.sh")

  vars = {
    MINECRAFT_VERSION    = var.game_version
    S3_BUCKET            = var.s3_bucket_name
    EC2_CPU_ARCHITECTURE = var.x86_64_package_name
    JAVA_XMS             = var.min_memory
    JAVA_XMX             = var.max_memory
  }
}
