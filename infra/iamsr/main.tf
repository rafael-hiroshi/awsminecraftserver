resource "aws_iam_instance_profile" "ec2_profile" {
  depends_on = [
    aws_iam_role_policy_attachment.aws_iam_kms_policy_attach,
    aws_iam_role_policy_attachment.aws_iam_s3_policy_attach,
    aws_iam_role_policy_attachment.aws_iam_managed_policy_attach
  ]
  name = "EC2MinecraftInstanceProfile"
  role = aws_iam_role.ec2_service_role.name
}

resource "aws_iam_role_policy_attachment" "aws_iam_s3_policy_attach" {
  role       = aws_iam_role.ec2_service_role.name
  policy_arn = aws_iam_policy.s3_bucket.arn
}

resource "aws_iam_role_policy_attachment" "aws_iam_kms_policy_attach" {
  role       = aws_iam_role.ec2_service_role.name
  policy_arn = aws_iam_policy.kms_policy.arn
}

resource "aws_iam_role_policy_attachment" "aws_iam_managed_policy_attach" {
  for_each = toset([
    "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore",
    "arn:aws:iam::aws:policy/CloudWatchAgentAdminPolicy",
    "arn:aws:iam::aws:policy/service-role/AmazonEC2RoleforSSM"
  ])

  role       = aws_iam_role.ec2_service_role.name
  policy_arn = each.value
}

resource "aws_iam_role" "ec2_service_role" {
  name               = "EC2MinecraftServiceRole"
  assume_role_policy = jsonencode({
    Version   = "2012-10-17"
    Statement = [
      {
        Action    = "sts:AssumeRole"
        Effect    = "Allow"
        Sid       = ""
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      },
    ]
  })
}

resource "aws_iam_policy" "s3_bucket" {
  name = "EC2MinecraftS3AccessPolicy"

  policy = jsonencode({
    Version   = "2012-10-17"
    Statement = [
      {
        "Effect" : "Allow",
        "Action" : [
          "s3:ListBucket"
        ],
        "Resource" : data.aws_s3_bucket.s3_bucket.arn
      },
      {
        "Effect" : "Allow",
        "Action" : [
          "s3:PutObject",
          "s3:GetObject",
          "s3:ListObjectVersions",
          "s3:GetObjectVersion"
        ],
        "Resource" : "${data.aws_s3_bucket.s3_bucket.arn}/*"
      }
    ]
  })
}

resource "aws_iam_policy" "kms_policy" {
  name = "EC2MinecraftKMSPolicy"

  policy = jsonencode({
    Version   = "2012-10-17"
    Statement = [
      {
        "Sid" : "VisualEditor0",
        "Effect" : "Allow",
        "Action" : "kms:*",
        "Resource" : "*"
      }
    ]
  })
}

