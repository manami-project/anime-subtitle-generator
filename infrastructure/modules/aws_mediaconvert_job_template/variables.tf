variable "s3_bucket_target_uri" {
  type = string
}

variable "region" {
  type = string
  description = "The AWS region in which the resources will be deployed."

  validation {
    condition = can(regex("[a-z]{2}-[a-z]+-\\d", var.region))
    error_message = "Invalid value for region. Region must be an AWS identifier such as: us-east-2."
  }
}

variable "name" {
  type = string
  description = "The template's name."
}