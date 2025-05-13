// S3 module variablesvariable
variable "bucket_name" {
  description = "Nome do S3 bucket"
  type        = string
}

variable "tags" {
  description = "tags"
  type        = map(string)
  default     = {}
}