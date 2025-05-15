#!/bin/bash

set -e  # Encerra em caso de erro

echo "🔄 Limpando diretórios antigos..."
rm -rf ../build/
mkdir -p ../build/python

echo "📦 Instalando dependências do requirements.txt..."
pip install -r ../requirements.txt -t ../build/python

echo "📁 Copiando código-fonte..."
cp ../app/src_lambda/validate_file.py ../build/python/

echo "🗜️  Compactando em lambda.zip..."
cd ../build/python
zip -r9 ../../lambda.zip .

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"

echo "📁 Copiando lambda.zip para app/src_lambda/..."
cp "$PROJECT_ROOT/lambda.zip" "$PROJECT_ROOT/app/src_lambda/"

echo "✅ Build completo! Arquivo gerado em: $PROJECT_ROOT/lambda.zip"
