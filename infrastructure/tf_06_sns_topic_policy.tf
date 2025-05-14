module "sns_topic_policy" {
  source     = "../aws/modules/policies/sns_topic_policy"
  topic_arn  = module.sns_topic_transaction.arn
  bucket_arn = module.raw_bucket.arn
  account_id = var.id_count

  depends_on = [module.raw_bucket, module.sns_topic_transaction]
}
