output "policy_arn" {
  description = "ARN da policy criada"
  value       = aws_iam_policy.this.arn
}
