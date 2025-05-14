// definicao de variaveis
variable "aws_region" {
  default ="us-east-1"
}

variable "id_count" {
  default ="452271769418"
}

variable "project_name" {
  default ="PROJECT_V1"
}
variable "centro_custo" {
  default ="001"
}

variable "sqs_queues" {
  type = map(object({
    name          = string
    filter_policy = map(any)
  }))
  default = {
    recebimento = {
      name          = "fila-recebimento"
      filter_policy = {
        prefix = ["recebimento"]
      }
    },
    processar = {
      name          = "fila-processar"
      filter_policy = {
        prefix = ["processar"]
      }
    }
  }
}

