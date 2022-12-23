variable "s3_bucket_name" {
  type = string
}

variable "lookup_ami" {
  type = bool
}

variable "game_version" {
  type = string
  default = "1.19.2"
}

variable "x86_64_package_name" {
  type = string
  default = "x86_64"
}

variable "arm_package_name" {
  type = string
  default = "aarch64"
}

variable "min_memory" {
  type = string
  default = "2048M"
}

variable "max_memory" {
  type = string
  default = "3584M"
}
