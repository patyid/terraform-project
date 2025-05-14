import boto3
import io
import pandas as pd
import json

s3 = boto3.client('s3')

def lambda_handler(event, context):
    expected_columns = {'coluna1', 'coluna2', 'coluna3'}

    for record in event['Records']:
        message = json.loads(record['body'])
        bucket = message['Records'][0]['s3']['bucket']['name']
        key = message['Records'][0]['s3']['object']['key']

        print(f"Verificando arquivo: s3://{bucket}/{key}")

        # Baixa o arquivo CSV do S3 (somente o cabeçalho)
        response = s3.get_object(Bucket=bucket, Key=key)
        content = response['Body'].read().decode('utf-8')

        # Lê apenas a primeira linha (cabeçalho)
        header_line = content.splitlines()[0]
        header_columns = [col.strip() for col in header_line.split(',')]

        # Verifica se todos os campos esperados estão presentes
        if expected_columns.issubset(set(header_columns)):
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
        else:
            print(f"Arquivo {key} não possui as colunas esperadas. Ignorando.")
