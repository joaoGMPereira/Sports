#!/bin/sh

# Script para incrementar versão e publicar aplicativos no TestFlight
# Uso: ./publishToTestFlight.sh [app_name]
# Onde app_name pode ser: KettleGym, ZenithSample ou ZenithCoreSample

set -e

ROOT_DIR="$(git rev-parse --show-toplevel)"
cd "$ROOT_DIR"

APP_NAME=$1

if [ -z "$APP_NAME" ]; then
    echo "Por favor, especifique qual aplicativo deseja publicar: KettleGym, ZenithSample ou ZenithCoreSample"
    exit 1
fi

echo "Iniciando processo de publicação do $APP_NAME no TestFlight..."

# Função para incrementar a versão de build
increment_build_version() {
    echo "Incrementando número de build..."
    
    # Incrementa a versão no arquivo de templates do Tuist
    TEMPLATES_FILE="$ROOT_DIR/Tuist/ProjectDescriptionHelpers/Project+Templates.swift"
    
    if [ -f "$TEMPLATES_FILE" ]; then
        # Obtém a versão atual e incrementa
        CURRENT_VERSION=$(grep "CURRENT_PROJECT_VERSION" "$TEMPLATES_FILE" | sed -E 's/.*"([0-9]+)".*/\1/')
        
        if [ -n "$CURRENT_VERSION" ]; then
            # Adiciona zeros à esquerda se necessário para manter 3 dígitos
            NEW_VERSION=$(printf "%03d" $((10#$CURRENT_VERSION + 1)))
            
            echo "Incrementando build number de $CURRENT_VERSION para $NEW_VERSION"
            
            # Substitui a versão
            sed -i '' -E "s/\"CURRENT_PROJECT_VERSION\": \"[0-9]+\"/\"CURRENT_PROJECT_VERSION\": \"$NEW_VERSION\"/" "$TEMPLATES_FILE"
        else
            echo "Não foi possível encontrar o número de build no arquivo $TEMPLATES_FILE"
            exit 1
        fi
    else
        echo "Arquivo de templates do Tuist não encontrado em $TEMPLATES_FILE"
        exit 1
    fi
    
    # Regenera projetos com Tuist
    echo "Regenerando projetos após atualização de versão..."
    "$ROOT_DIR/Scripts/tuistGenerate.sh" --main-only
}

# Certificados
echo "Verificando certificados..."
bundle exec fastlane setup_certificates_prod

# Incrementa a versão
increment_build_version

# Publicação com base no app selecionado
case "$APP_NAME" in
    "KettleGym")
        echo "Publicando KettleGym no TestFlight..."
        bundle exec fastlane publish_kettlegym_testflight_no_increment
        ;;
    "ZenithSample")
        echo "Publicando ZenithSample no TestFlight..."
        bundle exec fastlane publish_zenithsample_testflight_no_increment
        ;;
    "ZenithCoreSample")
        echo "Publicando ZenithCoreSample no TestFlight..."
        bundle exec fastlane publish_zenithcoresample_testflight_no_increment
        ;;
    *)
        echo "Aplicativo não reconhecido. Use KettleGym, ZenithSample ou ZenithCoreSample."
        exit 1
        ;;
esac

echo "Processo de publicação concluído com sucesso!"