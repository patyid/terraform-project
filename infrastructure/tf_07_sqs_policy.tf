module "sqs_queue_policy" {
  source      = "../aws/modules/policies/sqs_queue_policy"
  for_each = var.sqs_queues
  queue_arn = module.sqs_transaction[each.key].arn
  queue_url = module.sqs_transaction[each.key].url
  topic_arn = module.sns_topic_transaction.arn

  depends_on = [module.sqs_transaction, module.sns_topic_transaction]
}

