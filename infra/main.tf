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

resource "aws_instance" "minecraft_server" {
  ami           = var.ec2_ami
  instance_type = "t3.micro"
  hibernation = true
  iam_instance_profile = aws_iam_instance_profile.ec2_profile.name
  security_groups = [aws_security_group.allow_game_traffic.name]

  root_block_device {
    delete_on_termination = false
    encrypted = true
    iops = 3000
    throughput = 125
    kms_key_id = var.kms_key_arn
    volume_size = 12
    volume_type = "gp3"
  }

  tags = {
    Name = "Minecraft Server"
  }
}

resource "aws_iam_instance_profile" "ec2_profile" {
  name = "MinecraftServerEC2InstanceProfile"
  role = aws_iam_role.ec2_service_role.name
}

resource "aws_security_group" "allow_game_traffic" {
  name        = "Minecraft Server Instance SG"
  description = "Allow default minecraft game inbound traffic"
  vpc_id      = var.vpc_id

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

resource "aws_iam_role_policy_attachment" "aws_iam_role_attach"{
  role       = aws_iam_role.ec2_service_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

resource "aws_iam_role" "ec2_service_role" {
  name = "MinecraftServerEC2ServiceRole"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Sid    = ""
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      },
    ]
  })
}

resource "aws_iam_policy" "s3_bucket" {
  name = "MinecraftServerS3AccessPolicy"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        "Effect": "Allow",
        "Action": [
          "s3:ListBucket"
        ],
        "Resource": var.s3_bucket_arn
      },
      {
        "Effect": "Allow",
        "Action": [
          "s3:PutObject",
          "s3:GetObject"
        ],
        "Resource": "${var.s3_bucket_arn}/*"
      }
    ]
  })
}

resource "aws_iam_policy" "kms_policy" {
  name = "MinecraftServerKMSPolicy"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        "Sid": "VisualEditor0",
        "Effect": "Allow",
        "Action": "kms:*",
        "Resource": "*"
      }
    ]
  })
}