#!/bin/bash

# Script para facilitar a geração de arquivos Sample para componentes Zenith

# Diretório base do projeto - usando caminho absoluto para evitar problemas
BASE_DIR="/Users/ipereira.mazzatech/KettleGym"
PYTHON_SCRIPT="$BASE_DIR/Scripts/Generate/SampleGenerator/generate_samples.py"
LOG_FILE="$BASE_DIR/Scripts/Generate/SampleGenerator/sample_generator.log"

# Função para registrar logs
log_message() {
    local level="$1"
    local message="$2"
    local timestamp=$(date +"%Y-%m-%d %H:%M:%S")
    echo "[$timestamp] [$level] $message" >> "$LOG_FILE"
    
    if [ "$level" == "ERROR" ]; then
        echo -e "\033[0;31m[$level] $message\033[0m"  # Vermelho para erros
    elif [ "$level" == "WARNING" ]; then
        echo -e "\033[0;33m[$level] $message\033[0m"  # Amarelo para avisos
    else
        echo "[$level] $message"  # Normal para info
    fi
}

# Verifica se o Python 3 está instalado
check_dependencies() {
    if ! command -v python3 &> /dev/null; then
        log_message "ERROR" "Python 3 não está instalado. Por favor, instale o Python 3."
        exit 1
    fi
    
    # Verificar se o diretório do script existe
    if [ ! -f "$PYTHON_SCRIPT" ]; then
        log_message "ERROR" "Script Python não encontrado: $PYTHON_SCRIPT"
        exit 1
    fi
}

# Verifica se o componente existe
check_component() {
    local component="$1"
    local components_paths=(
        "$BASE_DIR/Packages/Zenith/Sources/Zenith/BaseElements/Natives/$component"
        "$BASE_DIR/Packages/Zenith/Sources/Zenith/Components/Customs/$component"
    )
    
    for path in "${components_paths[@]}"; do
        if [ -d "$path" ]; then
            return 0  # Componente encontrado
        fi
    done
    
    log_message "ERROR" "Componente '$component' não encontrado nos diretórios esperados."
    log_message "INFO" "Verifique se o nome está correto e se o componente existe."
    return 1  # Componente não encontrado
}

# Verifica se o componente foi especificado
if [ "$#" -ne 1 ]; then
    log_message "ERROR" "Uso: $0 <nome_do_componente>"
    log_message "INFO" "Exemplo: $0 Text"
    exit 1
fi

COMPONENT_NAME="$1"

# Verificar dependências
check_dependencies

# Verificar se o componente existe
if ! check_component "$COMPONENT_NAME"; then
    exit 1
fi

# Executa o script Python para gerar o Sample
log_message "INFO" "Gerando Sample para o componente: $COMPONENT_NAME"
python3 "$PYTHON_SCRIPT" "$COMPONENT_NAME"

# Verifica o resultado
if [ $? -eq 0 ]; then
    log_message "INFO" "Sample gerado com sucesso!"
    
    # Localiza o arquivo gerado
    SAMPLE_FILE=$(find "$BASE_DIR/Packages/ZenithSample/ZenithSample" -name "${COMPONENT_NAME}Sample.swift")
    
    if [ -n "$SAMPLE_FILE" ]; then
        log_message "INFO" "Arquivo Sample criado em: $SAMPLE_FILE"
        
        # Verifica se o comando 'code' está disponível para abrir o VS Code
        if command -v code >/dev/null 2>&1; then
            # Abre o arquivo gerado no VS Code (opcional)
            echo "Deseja abrir o arquivo gerado no VS Code? (s/n)"
            read -r OPEN_FILE
            
            if [[ "$OPEN_FILE" =~ ^[Ss]$ ]]; then
                log_message "INFO" "Abrindo arquivo no VS Code: $SAMPLE_FILE"
                code "$SAMPLE_FILE"
            fi
        else
            log_message "WARNING" "O comando 'code' não está disponível. Para abrir no VS Code, você pode:"
            log_message "INFO" "1. Adicionar o VS Code ao PATH" 
            log_message "INFO" "2. Abrir manualmente o arquivo: $SAMPLE_FILE"
        fi
    else
        log_message "WARNING" "Arquivo Sample foi gerado, mas não foi possível localizá-lo."
        log_message "INFO" "Verifique manualmente na pasta: $BASE_DIR/Packages/ZenithSample/ZenithSample"
    fi
else
    log_message "ERROR" "Erro ao gerar Sample para o componente: $COMPONENT_NAME"
    log_message "INFO" "Verifique o log para mais detalhes."
    exit 1
fi