variable "account_id" {
  type        = string
  description = "id da conta"
}

variable "bucket_arn" {
  type        = string
  description = "Arn do bucket"
}

variable "topic_arn" {
  type        = string
  description = "The ARN of the SNS topic"
}
