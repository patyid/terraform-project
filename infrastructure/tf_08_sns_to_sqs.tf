module "sns_to_sqs" {
  source = "../aws/modules/sns_subscription"
  topic_arn = module.sns_topic_transaction.arn
  endpoint = module.sqs_transaction.arn
  protocol = "sqs"
  raw_message_delivery = true
  depends_on = [module.sns_topic_transaction, module.sqs_transaction]
}