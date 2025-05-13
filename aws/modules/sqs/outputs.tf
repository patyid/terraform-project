output "arn" {
  description = "ARN da fila SQS"
  value       = aws_sqs_queue.this.arn
}

output "url" {
  description = "URL da fila SQS"
  value       = aws_sqs_queue.this.url
}
