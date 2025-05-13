variable "bucket_name" {
  type        = string
  description = "The name of the S3 bucket"
}

variable "topic_arn" {
  type        = string
  description = "The ARN of the SNS topic"
}
