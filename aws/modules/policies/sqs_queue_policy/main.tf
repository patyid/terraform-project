data "aws_iam_policy_document" "sns_to_sqs" {
  statement {
    sid    = "Allow-SNS-SendMessage"
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["sns.amazonaws.com"]
    }

    actions   = ["sqs:SendMessage"]
    resources = [var.queue_arn]

    condition {
      test     = "ArnEquals"
      variable = "aws:SourceArn"
      values   = [var.topic_arn]
    }
  }
}

resource "aws_sqs_queue_policy" "this" {
  queue_url = var.queue_url
  policy    = data.aws_iam_policy_document.sns_to_sqs.json
}
