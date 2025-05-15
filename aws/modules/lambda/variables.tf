variable "lambda_name" {
  description = "Nome da função Lambda"
  type        = string
}

variable "handler" {
  description = "Handler da função"
  type        = string
}

variable "runtime" {
  description = "Runtime da Lambda"
  type        = string
}

variable "zip_path" {
  description = "Caminho para o lambda.zip"
  type        = string
}

variable "timeout" {
  type    = number
  default = 1
}

variable "memory_size" {
  type    = number
  default = 128
}

variable "tags" {
  description = "tags"
  type        = map(string)
  default     = {}
}