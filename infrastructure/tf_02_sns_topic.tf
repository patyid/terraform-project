module "sns_topic_transaction" {
  source = "../aws/modules/sns"
  name = "sns_transaction"

  tags = {
    PROJECT_NAME  = var.project_name
    CENTRO_CUSTO  = var.centro_custo
  }
}