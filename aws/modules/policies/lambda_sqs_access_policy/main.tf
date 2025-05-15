resource "aws_iam_policy" "sqs_access" {
  name = "${var.lambda_name}-sqs-access"

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Action = [
          "sqs:ReceiveMessage",
          "sqs:DeleteMessage",
          "sqs:GetQueueAttributes"
        ],
        Resource = var.queue_arn
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "lambda_sqs_access" {
  role       = var.execution_role_name
  policy_arn = aws_iam_policy.sqs_access.arn
}
