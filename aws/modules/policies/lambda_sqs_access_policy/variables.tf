variable "queue_arn" {
  description = "ARN of the SQS queue"
  type        = string
}
variable "lambda_name" {
  description = "nome da lambda"
  type        = string
}

variable "execution_role_name" {
  description = "nome execution_role_name"
  type        = string
}
