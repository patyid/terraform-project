variable "queue_url" {
  type        = string
  description = "The URL of the SQS queue"
}

variable "queue_arn" {
  type        = string
  description = "The ARN of the SQS queue"
}

variable "topic_arn" {
  type        = string
  description = "The ARN of the SNS topic"
}
