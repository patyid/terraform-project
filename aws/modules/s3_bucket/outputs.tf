output "id" {
  description = "id do bucket"
  value       = aws_s3_bucket.this.id
}

output "bucket_name" {
  description = "Nome do bucket S3"
  value       = aws_s3_bucket.this.bucket
}

output "arn" {
  description = "arn do bucket S3"
  value       = aws_s3_bucket.this.arn
}