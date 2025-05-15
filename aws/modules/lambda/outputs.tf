// Lambda module outputs
output "lambda_arn" {
  value = aws_lambda_function.this.arn
}

output "lambda_name" {
  value = aws_lambda_function.this.function_name
}

output "execution_role_name" {
  description = "Nome da IAM role da Lambda"
  value       = aws_iam_role.lambda_exec.name
}

output "execution_role_arn" {
  description = "ARN da IAM role da Lambda"
  value       = aws_iam_role.lambda_exec.arn
}