resource "aws_sns_topic" this {
  name = var.name
  tags =var.tags
}