#!/bin/bash

# Verifica se o Tuist está instalado
if ! command -v tuist &> /dev/null; then
    echo "Tuist não encontrado. Instalando..."
    curl -Ls https://install.tuist.io | bash
fi

# Diretório do projeto
PROJECT_DIR="$(pwd)"
echo "Gerando projetos com Tuist no diretório: $PROJECT_DIR"

# Opção para gerar apenas o projeto principal
ONLY_MAIN=false
# Opção para gerar apenas os samples
ONLY_SAMPLES=false

# Processa argumentos de linha de comando
while [[ $# -gt 0 ]]; do
    case $1 in
        --main-only)
            ONLY_MAIN=true
            shift
            ;;
        --samples-only)
            ONLY_SAMPLES=true
            shift
            ;;
        *)
            shift
            ;;
    esac
done

# Gerar o projeto principal se necessário
if [[ "$ONLY_MAIN" == true || "$ONLY_SAMPLES" == false ]]; then
    cd "$PROJECT_DIR"
    echo "Gerando projeto principal..."
    tuist generate
fi

# Gerar os projetos de amostra se necessário
if [[ "$ONLY_SAMPLES" == true || "$ONLY_MAIN" == false ]]; then
    echo "Gerando ZenithCoreSample..."
    cd "$PROJECT_DIR/Packages/ZenithCoreSample"
    tuist generate

    echo "Gerando ZenithSample..."
    cd "$PROJECT_DIR/Packages/ZenithSample"
    tuist generate
fi

echo "Projetos gerados com sucesso!"