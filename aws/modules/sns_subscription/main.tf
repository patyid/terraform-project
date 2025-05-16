resource "aws_sns_topic_subscription" "this" {
  topic_arn             = var.topic_arn
  protocol              = var.protocol
  endpoint              = var.endpoint
  raw_message_delivery  = var.raw_message_delivery
  filter_policy = var.filter_policy
  filter_policy_scope = var.filter_policy_scope
}
