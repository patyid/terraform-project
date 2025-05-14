module "sqs_transaction" {
  source = "../aws/modules/sqs"
  for_each = var.sqs_queues
  name = each.value.name

  tags = {
    PROJECT_NAME  = var.project_name
    CENTRO_CUSTO  = var.centro_custo
  }
}