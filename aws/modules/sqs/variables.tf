variable "name" {
  description = "Nome do SNS"
  type        = string
}

variable "tags" {
  description = "tags"
  type        = map(string)
  default     = {}
}


