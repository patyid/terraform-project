output "glue_job_name" {
  description = "Nome do Glue Job criado"
  value       = aws_glue_job.this.name
}

output "glue_role_arn" {
  description = "ARN da Role do Glue"
  value       = aws_iam_role.glue_role.arn
}

#glue_role.name
output "glue_role_name" {
  description = "Nome da Role do Glue"
  value       = aws_iam_role.glue_role.name
}