variable "glue_job_name" {
  description = "Nome do Glue Job"
  type        = string
}

variable "glue_role_name" {
  description = "Nome da role para Glue"
  type        = string
  default     = "glue-job-role"
}

variable "script_bucket_name" {
  description = "Nome do bucket onde está o script"
  type        = string
}

variable "script_s3_key" {
  description = "Key do script no S3 (ex: glue_job_package.zip)"
  type        = string
  default     = "glue_job_package.zip"
}

variable "number_of_workers" {
  description = "Número de workers para o Glue Job"
  type        = number
  default     = 2
}

variable "worker_type" {
  description = "Tipo de worker (G.1X ou G.2X)"
  type        = string
  default     = "G.1X"
}

variable "default_arguments" {
  description = "Argumentos padrões do Glue Job"
  type        = map(string)
}
