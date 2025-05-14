resource "aws_s3_object" "prefix_s3" {
  for_each = toset(var.prefix)

  bucket  = var.bucket_name
  key     = each.value
  content = ""
}
