#!/bin/bash

# Script para facilitar a geração de arquivos Sample para componentes Zenith

# Diretório base do projeto - usando caminho absoluto para evitar problemas
BASE_DIR="/Users/ipereira.mazzatech/KettleGym"
PYTHON_SCRIPT="$BASE_DIR/Scripts/Generate/SampleGenerator/generate_samples.py"

# Verifica se o componente foi especificado
if [ "$#" -ne 1 ]; then
    echo "Uso: $0 <nome_do_componente>"
    echo "Exemplo: $0 Text"
    exit 1
fi

COMPONENT_NAME="$1"

# Executa o script Python para gerar o Sample
echo "Gerando Sample para o componente: $COMPONENT_NAME"
python3 "$PYTHON_SCRIPT" "$COMPONENT_NAME"

# Verifica o resultado
if [ $? -eq 0 ]; then
    echo "Sample gerado com sucesso!"
    
    # Localiza o arquivo gerado
    SAMPLE_FILE=$(find "$BASE_DIR/Packages/ZenithSample/ZenithSample" -name "${COMPONENT_NAME}Sample.swift")
    
    if [ -n "$SAMPLE_FILE" ]; then
        echo "Arquivo Sample criado em: $SAMPLE_FILE"
        
        # Verifica se o comando 'code' está disponível para abrir o VS Code
        if command -v code >/dev/null 2>&1; then
            # Abre o arquivo gerado no VS Code (opcional)
            echo "Deseja abrir o arquivo gerado no VS Code? (s/n)"
            read -r OPEN_FILE
            
            if [[ "$OPEN_FILE" =~ ^[Ss]$ ]]; then
                echo "Abrindo arquivo no VS Code: $SAMPLE_FILE"
                code "$SAMPLE_FILE"
            fi
        else
            echo "O comando 'code' não está disponível. Para abrir no VS Code, você pode:"
            echo "1. Adicionar o VS Code ao PATH" 
            echo "2. Abrir manualmente o arquivo: $SAMPLE_FILE"
        fi
    else
        echo "Arquivo não encontrado."
    fi
else
    echo "Erro ao gerar Sample para o componente: $COMPONENT_NAME"
    exit 1
fi