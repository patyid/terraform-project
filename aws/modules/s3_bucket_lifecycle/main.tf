resource "aws_s3_bucket_lifecycle_configuration" "lifecycle" {
  bucket = var.bucket_id

  rule {
    id     = "DeleteTempFiles"
    status = "Enabled"

    filter {
      prefix = var.prefix
    }

    expiration {
      days = 1
    }
  }
}