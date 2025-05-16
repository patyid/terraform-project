import boto3
import json

s3 = boto3.client('s3')

def lambda_handler(event, context):
    for record in event['Records']:
        try:
            message = json.loads(record['body'])
            bucket = message['Records'][0]['s3']['bucket']['name']
            key = message['Records'][0]['s3']['object']['key']
            print(f"Verificando arquivo: s3://{bucket}/{key}")
            # Baixa o arquivo CSV do S3 (somente o cabeçalho)
            response = s3.get_object(Bucket=bucket, Key=key)
            content = response['Body'].read().decode('utf-8')
            if do_validate(response,bucket,key):
                do_mv_file(bucket,key)
            else:
                print(f"Arquivo {key} não possui as colunas esperadas. Ignorando.")
        except Exception as e:
            print(f"Erro no processamento: {e}")
            raise

def do_validate(response,bucket,key):
    expected_columns = {'id_client', 'currency', 'amount','date_transaction'}
    content = response['Body'].read().decode('utf-8')
    # Lê apenas a primeira linha (cabeçalho)
    line = content.splitlines()
    if not line:
        print(f"Arquivo {key} está vazio.")
        print(f"cabeçalho {line}")
        return False

    header_line = line[0]
    header_columns = [col.strip() for col in header_line.split(',')]

    # Verifica se todos os campos clear
    # esperados estão presentes
    print(f"header_columns {header_columns}")
    if expected_columns.issubset(set(header_columns)):
      return True
    else:
      return False

def do_mv_file(bucket,key):
    new_key = key.replace("recebimento/", "processar/")  # ajuste conforme a pasta
    print(f"Arquivo válido. Movendo para: s3://{bucket}/{new_key}")

    # Copia o objeto para o novo destino
    s3.copy_object(
        Bucket=bucket,
        CopySource={'Bucket': bucket, 'Key': key},
        Key=new_key
    )
    # Exclui o original
    s3.delete_object(Bucket=bucket, Key=key)



