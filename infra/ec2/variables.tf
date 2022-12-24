variable "lookup_ami" {
  type = bool
}

variable "instance_role_name" {
  type = string
}

variable "s3_bucket_name" {
  type = string
}

variable "game_version" {
  type = string
}

variable "x86_64_package_name" {
  type    = string
  default = "x86_64"
}

variable "arm_package_name" {
  type    = string
  default = "aarch64"
}

variable "min_memory" {
  type = string
}

variable "max_memory" {
  type = string
}

variable "instance_type" {
  type = string
}
