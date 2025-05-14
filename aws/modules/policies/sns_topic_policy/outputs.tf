output "sns_topic_policy_arn" {
  description = "ARN da política do tópico SNS"
  value       = aws_sns_topic_policy.this.arn
}
// Lambda module outputs