module "s3_bucket_policy" {
  source      = "../aws/modules/policies/s3_bucket_policy"
  bucket_name = module.raw_bucket.bucket_name
  topic_arn   = module.sns_topic_transaction.arn

  depends_on = [module.raw_bucket, module.sns_topic_transaction]
}