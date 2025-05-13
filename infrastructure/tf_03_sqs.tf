module "sqs_transaction" {
  source = "../aws/modules/sqs"
  name = "sqs_transaction"

  tags = {
    PROJECT_NAME  = var.project_name
    CENTRO_CUSTO  = var.centro_custo
  }
}