output "arn" {
  description = "ARN do SNS"
  value       = aws_sns_topic.this.arn
}
