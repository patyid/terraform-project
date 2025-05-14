variable "topic_arn" {
  description = "ARN do tópico SNS"
  type        = string
}

variable "protocol" {
  description = "Protocolo da inscrição (sqs, lambda, email, etc)"
  type        = string
}

variable "endpoint" {
  description = "ARN do destino (ex: SQS ARN, Lambda ARN, etc)"
  type        = string
}

variable "raw_message_delivery" {
  description = "Entrega sem formatação JSON extra (relevante para SQS)"
  type        = bool
  default     = false
}

variable "filter_policy" {
  description = "SNS filter policy to apply to the subscription"
  type        = string
  default     = null
}