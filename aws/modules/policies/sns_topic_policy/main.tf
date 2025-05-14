data "aws_iam_policy_document" "aws_sns_topic_policy" {
  statement {
    sid    = "AllowS3Publish"
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["s3.amazonaws.com"]
    }

    actions   = ["sns:Publish"]
    resources = [var.topic_arn]

    condition {
      test     = "ArnLike"
      variable = "aws:SourceArn"
      values   = [var.bucket_arn]
    }

    condition {
      test     = "StringEquals"
      variable = "aws:SourceAccount"
      values   = [var.account_id]
    }
  }
}

resource "aws_sns_topic_policy" "this" {
  arn    = var.topic_arn
  policy = data.aws_iam_policy_document.aws_sns_topic_policy.json
}
