module "lambda_validate_csv" {
  source      = "../aws/modules/lambda"
  lambda_name = "validate-csv"
  handler     = "validate_file.lambda_handler"
  zip_path    = "../app/src_lambda/lambda.zip"
  runtime     = "python3.12"
}

module "lambda_permission" {
  source      = "../aws/modules/policies/lambda_policy"
  function_name = module.lambda_validate_csv.lambda_name
  sqs_queue_arn =   module.sqs_transaction["recebimento"].arn
  depends_on = [module.lambda_validate_csv, module.sqs_transaction]
}

module "lambda_sqs_access_permission" {
  source      = "../aws/modules/policies/lambda_sqs_access_policy"
  execution_role_name = module.lambda_validate_csv.execution_role_name
  lambda_name = module.lambda_validate_csv.lambda_name
  queue_arn =  module.sqs_transaction["recebimento"].arn
  depends_on = [module.lambda_permission, module.sqs_transaction]
}

module "lambda_subscription" {
  source = "../aws/modules/lambda_subscription"
  lambda_arn    = module.lambda_validate_csv.lambda_arn
  sqs_queue_arn = module.sqs_transaction["recebimento"].arn

  depends_on = [module.lambda_validate_csv, module.sqs_transaction]
}
