#!/bin/bash

# Script para abrir apenas o projeto KettleGym sem os samples
cd "$(dirname "$0")/.."
PROJECT_DIR="$(pwd)"

echo "Gerando apenas o projeto KettleGym..."

# Executar o tuist generate na raiz do projeto
tuist generate

echo "Projeto KettleGym gerado com sucesso!"
echo "Abrindo o KettleGym.xcworkspace..."

# Abrir o workspace com o Xcode
open KettleGym.xcworkspace