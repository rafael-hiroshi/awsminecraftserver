variable "s3_bucket_name" {
  type = string
}

variable "amazon_linux_ami" {
  type = string
}

variable "kms_key_arn" {
  type = string
}

variable "account_id" {
  type = string
}

variable "lookup_ami" {
  type = bool
}
