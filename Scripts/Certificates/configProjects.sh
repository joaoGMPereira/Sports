#!/bin/bash

# Este script configura os certificados para um projeto específico
# Uso: ./configProjects.sh <nome-do-projeto> <caminho-do-projeto> "<arquivos-yml>" "<arquivos-project-swift>" "<arquivos-targets-swift>" "<arquivos-config-swift>"

PROJECT_NAME=$1
PROJECT_PATH=$2
YML_FILES=$3
TUIST_PROJECT_FILES=$4
TUIST_TARGETS_FILES=$5
TUIST_CONFIG_FILES=$6

if [ -z "$PROJECT_NAME" ] || [ -z "$PROJECT_PATH" ]; then
    echo "Erro: Parâmetros insuficientes"
    echo "Uso: ./configProjects.sh <nome-do-projeto> <caminho-do-projeto> \"<arquivos-yml>\" \"<arquivos-project-swift>\" \"<arquivos-targets-swift>\" \"<arquivos-config-swift>\""
    exit 1
fi

echo "Configurando certificados para $PROJECT_NAME em $PROJECT_PATH..."

# Defina aqui os detalhes dos certificados
DEVELOPMENT_TEAM="XXXXXXXXXX"  # Substitua pelo seu Team ID
CODE_SIGN_IDENTITY="iPhone Developer"
PROVISIONING_PROFILE_NAME="match Development com.your.bundle.id"
PROVISIONING_PROFILE_DISTRIBUTION="match AppStore com.your.bundle.id"

# Contador para saber se algum arquivo foi processado
FILES_PROCESSED=0

# Processa arquivos project.yml (XcodeGen)
if [ -n "$YML_FILES" ]; then
    for yml_file in $YML_FILES; do
        echo "Atualizando configurações em $yml_file (XcodeGen)"
        
        # Exemplo de alteração com sed - ajuste conforme a estrutura do seu arquivo
        sed -i '' "s/DEVELOPMENT_TEAM: .*/DEVELOPMENT_TEAM: $DEVELOPMENT_TEAM/" "$yml_file"
        sed -i '' "s/CODE_SIGN_IDENTITY: .*/CODE_SIGN_IDENTITY: \"$CODE_SIGN_IDENTITY\"/" "$yml_file"
        sed -i '' "s/PROVISIONING_PROFILE_SPECIFIER: .*/PROVISIONING_PROFILE_SPECIFIER: \"$PROVISIONING_PROFILE_NAME\"/" "$yml_file"
        
        echo "✅ Configuração XcodeGen concluída para $yml_file"
        FILES_PROCESSED=$((FILES_PROCESSED+1))
    done
fi

# Processa arquivos Project.swift (Tuist)
if [ -n "$TUIST_PROJECT_FILES" ]; then
    for tuist_file in $TUIST_PROJECT_FILES; do
        echo "Atualizando configurações em $tuist_file (Tuist)"
        
        # Atualiza o arquivo Project.swift
        sed -i '' "s/teamId: \".*\"/teamId: \"$DEVELOPMENT_TEAM\"/" "$tuist_file"
        sed -i '' "s/developmentTeam: \".*\"/developmentTeam: \"$DEVELOPMENT_TEAM\"/" "$tuist_file"
        
        echo "✅ Configuração Tuist (Project.swift) concluída para $tuist_file"
        FILES_PROCESSED=$((FILES_PROCESSED+1))
    done
fi

# Processa arquivos Targets.swift (Tuist)
if [ -n "$TUIST_TARGETS_FILES" ]; then
    for targets_file in $TUIST_TARGETS_FILES; do
        echo "Atualizando configurações em $targets_file (Tuist)"
        
        # Atualiza o arquivo Targets.swift
        sed -i '' "s/codeSignIdentity: \".*\"/codeSignIdentity: \"$CODE_SIGN_IDENTITY\"/" "$targets_file"
        sed -i '' "s/provisioningProfileSpecifier: \".*\"/provisioningProfileSpecifier: \"$PROVISIONING_PROFILE_NAME\"/" "$targets_file"
        sed -i '' "s/developmentTeam: \".*\"/developmentTeam: \"$DEVELOPMENT_TEAM\"/" "$targets_file"
        
        echo "✅ Configuração Tuist (Targets.swift) concluída para $targets_file"
        FILES_PROCESSED=$((FILES_PROCESSED+1))
    done
fi

# Processa arquivos Config.swift (Tuist)
if [ -n "$TUIST_CONFIG_FILES" ]; then
    for config_file in $TUIST_CONFIG_FILES; do
        echo "Atualizando configurações em $config_file (Tuist Config)"
        
        # Atualiza as configurações no arquivo Config.swift
        sed -i '' "s/static let teamId = \".*\"/static let teamId = \"$DEVELOPMENT_TEAM\"/" "$config_file"
        sed -i '' "s/static let codeSignIdentity = \".*\"/static let codeSignIdentity = \"$CODE_SIGN_IDENTITY\"/" "$config_file"
        
        echo "✅ Configuração Tuist (Config.swift) concluída para $config_file"
        FILES_PROCESSED=$((FILES_PROCESSED+1))
    done
fi

# Verifica se algum arquivo foi processado
if [ $FILES_PROCESSED -eq 0 ]; then
    echo "❌ Nenhum arquivo de configuração válido encontrado para o projeto $PROJECT_NAME"
    exit 1
else
    echo "✅ Total de $FILES_PROCESSED arquivos configurados para $PROJECT_NAME"
fi
