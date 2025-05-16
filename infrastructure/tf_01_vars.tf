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
    name               = string
    filter_policy      = any
    filter_policy_scope = optional(string, "MessageBody")
  }))
  default = {
    recebimento = {
      name = "fila-recebimento"
      filter_policy = {
        Records = {
          s3 = {
            object = {
              key = [
                { prefix = "recebimento/" }
              ]
            }
          }
        }
      }
      filter_policy_scope = "MessageBody"
    },
    processar = {
      name = "fila-processar"
      filter_policy = {
        Records = {
          s3 = {
            object = {
              key = [
                { prefix = "processar/" }
              ]
            }
          }
        }
      }
      filter_policy_scope = "MessageBody"
    }
  }
}