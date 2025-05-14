module "sns_to_sqs" {
  source = "../aws/modules/sns_subscription"
  for_each = var.sqs_queues

  topic_arn = module.sns_topic_transaction.arn
  endpoint = module.sqs_transaction[each.key].arn
  protocol = "sqs"
  raw_message_delivery = true
  filter_policy        = jsonencode(each.value.filter_policy)

  depends_on = [module.sns_topic_transaction, module.sqs_transaction]
}