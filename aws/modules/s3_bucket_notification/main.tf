resource "aws_s3_bucket_notification" "this" {
  bucket = var.bucket_name

  topic {
    topic_arn = var.topic_arn
    events    = var.events
  }

}
