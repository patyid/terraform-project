variable "policy_name" {
  description = "Nome da policy a ser criada"
  type        = string
}

variable "description" {
  description = "Descrição da policy"
  type        = string
  default     = "Glue job full access to all S3 buckets"
}

variable "role_name" {
  description = "Nome da IAM role a qual a policy será anexada"
  type        = string
}
