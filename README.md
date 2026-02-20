# Terraform Project — Documentação do Repositório

Projeto para provisionamento e processamento de dados na AWS usando Terraform, Lambda, SNS, SQS, S3, Glue e EMR.

## Visão Geral

Este repositório contém:
- Infraestrutura como código (Terraform) para criar recursos AWS necessários (S3, SNS, SQS, Lambdas, Glue, EMR).
- Código das funções e jobs (Lambda e Glue) para processamento/validação de arquivos.
- Scripts auxiliares para empacotar e construir artefatos.
- Testes unitários básicos.

Principais responsabilidades do projeto:
- Receber arquivos em um bucket S3.
- Notificar via SNS/SQS e acionar Lambda para validação/processamento.
- Rodar jobs Glue/EMR para transformações em larga escala.

## Estrutura do repositório

- `app/` — código da aplicação (lambda packages)
- `aws/modules/` — módulos Terraform reutilizáveis (s3_bucket, lambda, sns, sqs, glue_job, etc.)
- `infrastructure/` — stacks Terraform que orquestram os módulos e deployment
- `glue/` — código e jobs Glue (PySpark)
- `dag/`, `step/`, `cluster/` — exemplos e configurações para EMR e orquestração
- `script/` — scripts úteis: `build_lambda.sh`, `build_glue_package.sh`, `create-terraform-backend.sh`
- `tests/` — testes unitários (ex.: `tests/test_validate_file.py`)

## Requisitos

- Terraform (versão compatível com os módulos usados)
- AWS CLI configurado com credenciais/role apropriados
- Python 3.8+ (para empacotar Lambdas e rodar testes)
- `zip`, `unzip`, `bash` (usados nos scripts de build)

## Configuração local (desenvolvimento)

1. Criar e ativar um virtualenv (opcional):

```bash
python -m venv .venv
source .venv/bin/activate
```

2. Instalar dependências Python (se houver `requirements.txt`):

```bash
pip install -r requirements.txt
```

3. Rodar testes:

```bash
pytest tests
```

## Empacotar e construir artefatos

- Empacotar Lambda:

```bash
./script/build_lambda.sh
```

- Empacotar job Glue:

```bash
./script/build_glue_package.sh
```

Os scripts acima geram artefatos prontos para deploy (ex.: `zip` dos handlers e dependências).

## Deploy de Infraestrutura (Terraform)

1. Inicializar backend (se necessário):

```bash
./script/create-terraform-backend.sh
```

2. Ir até a pasta de infraestrutura e executar:

```bash
cd infrastructure
terraform init
terraform plan -out plan.tfplan
terraform apply plan.tfplan
```

Observações:
- Os módulos Terraform estão em `aws/modules/` e são referenciados pelos arquivos em `infrastructure/`.
- Reveja e ajuste `tf_01_vars.tf` e variáveis sensíveis antes do `apply`.

## Componentes principais

- `S3` — armazenamento de arquivos de input e output.
- `SNS` e `SQS` — notificações e enfileiramento entre serviços.
- `Lambda` — validação de arquivos e gatilhos.
- `Glue` — jobs PySpark para transformação de dados.
- `EMR` — clusters para processamento em larga escala (configurações em `dag/` e `cluster/`).

## Operações e Troubleshooting

- Logs Lambda: verificar no CloudWatch Logs.
- Glue jobs: checar logs e métricas no console AWS Glue/CloudWatch.
- Permissões: revise políticas em `aws/modules/policies/` caso recursos não consigam acessar S3/SNS/SQS.

## Contribuição

- Abra issues para bugs ou melhorias.
- Para PRs: siga o padrão de commits e inclua testes quando aplicável.

## Contato

Para dúvidas sobre este repositório, adicione uma issue ou fale com o responsável pela equipe de infraestrutura.

---

Arquivo gerado automaticamente pelo assistente. Ajuste seções específicas (variáveis, versões e comandos) conforme seu fluxo de trabalho.
