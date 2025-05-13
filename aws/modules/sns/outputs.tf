output "arn" {
  description = "ARN da fila SQS"
  value       = aws_sns_topic.this.arn
}
