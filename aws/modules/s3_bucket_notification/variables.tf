variable "bucket_name" {
  type        = string
  description = "Nome do bucket S3"
}

variable "topic_arn" {
  type        = string
  description = "ARN do tópico SNS que receberá os eventos"
}

variable "events" {
  type        = list(string)
  description = "Lista de eventos do S3 que disparam a notificação"
  default     = ["s3:ObjectCreated:*"]
}


