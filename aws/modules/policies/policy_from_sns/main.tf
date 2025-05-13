resource "aws_sqs_queue_policy" "this" {
  queue_url = var.queue_url

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid       = "Allow-SNS-SendMessage"
        Effect    = "Allow"
        Principal = "*"
        Action    = "SQS:SendMessage"
        Resource  = var.queue_arn
        Condition = {
          ArnEquals = {
            "aws:SourceArn" = var.topic_arn
          }
        }
      }
    ]
  })
}
