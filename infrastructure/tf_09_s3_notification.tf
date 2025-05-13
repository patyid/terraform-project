
module "s3_notification" {
  source = "../aws/modules/s3_bucket_notification"

  bucket_name = module.raw_bucket.bucket_name
  topic_arn   = module.sns_topic_transaction.arn
  events      = ["s3:ObjectCreated:*"]

  depends_on = [
    module.s3_bucket_policy,
    module.sns_to_sqs
  ]
}
