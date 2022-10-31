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

resource "aws_iam_role_policy_attachment" "aws_iam_role_attach"{
  for_each = toset([
    aws_iam_policy.s3_bucket.arn,
    aws_iam_policy.kms_policy.arn,
    "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore",
    "arn:aws:iam::aws:policy/CloudWatchAgentAdminPolicy"
  ])

  role       = aws_iam_role.ec2_instance_role.name
  policy_arn = each.value
}

resource "aws_iam_role" "ec2_instance_role" {
  name = "MinecraftServerEC2InstanceRole"
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
        "Resource": var.s3_bucket_name
      },
      {
        "Effect": "Allow",
        "Action": [
          "s3:PutObject",
          "s3:GetObject"
        ],
        "Resource": "${var.s3_bucket_name}/*"
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
