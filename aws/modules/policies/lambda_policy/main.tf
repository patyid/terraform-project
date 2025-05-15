resource "aws_lambda_permission" "allow_sqs" {
  statement_id  = "AllowExecutionFromSQS"
  action        = "lambda:InvokeFunction"
  function_name = var.function_name
  principal     = "sqs.amazonaws.com"
  source_arn    = var.sqs_queue_arn
}