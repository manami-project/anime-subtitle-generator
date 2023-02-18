variable "lambda_name" {
  type = string
}

variable "python_class_name" {
  type = string
}

variable "s3_bucket_name" {
  type = string
}

variable "env_vars" {
  type = map(string)
  default = {}
}

variable "sqs_arn" {
  type = string
}

variable "iam_policy_statements" {
  type = list(object({
    Sid = string
    Effect = string
    Action = list(string)
    Resource = list(string)
  }))
}