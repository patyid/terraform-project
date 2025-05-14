variable "queue_url" {
  description = "URL of the SQS queue"
  type        = string
}

variable "queue_arn" {
  description = "ARN of the SQS queue"
  type        = string
}

variable "topic_arn" {
  description = "ARN of the SNS topic"
  type        = string
}
