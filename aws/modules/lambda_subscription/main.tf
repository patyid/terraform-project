resource "aws_lambda_event_source_mapping" this{
  event_source_arn = var.sqs_queue_arn
  function_name    = var.lambda_arn
  batch_size       = 1
  enabled          = true
}