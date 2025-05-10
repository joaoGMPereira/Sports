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

# Tenta detectar automaticamente os dados dos certificados instalados
CERTIFICATE_INFO=$(security find-identity -p codesigning -v | grep -m 1 'iPhone Developer')
if [ -n "$CERTIFICATE_INFO" ]; then
    CODE_SIGN_IDENTITY=$(echo "$CERTIFICATE_INFO" | awk -F '"' '{print $2}')
    echo "Certificado detectado: $CODE_SIGN_IDENTITY"
    
    # Detectar automaticamente o Team ID
    TEAM_ID=$(security find-certificate -c "$CODE_SIGN_IDENTITY" -p | openssl x509 -noout -subject | grep -o 'OU=[^,]*' | cut -d '=' -f 2)
    if [ -n "$TEAM_ID" ]; then
        DEVELOPMENT_TEAM=$TEAM_ID
        echo "Team ID detectado: $DEVELOPMENT_TEAM"
    else
        echo "Aviso: Não foi possível detectar o Team ID. Usando valor padrão."
        DEVELOPMENT_TEAM="XXXXXXXXXX"  # Valor padrão
    fi
else
    echo "Aviso: Nenhum certificado de assinatura de código encontrado. Usando valores padrão."
    CODE_SIGN_IDENTITY="iPhone Developer"
    DEVELOPMENT_TEAM="XXXXXXXXXX"  # Valor padrão
    
    # Tentar obter o Team ID do Keychain como alternativa
    KEYCHAIN_TEAM_ID=$(security find-generic-password -s "Apple Developer Team ID" -w 2>/dev/null)
    if [ -n "$KEYCHAIN_TEAM_ID" ]; then
        DEVELOPMENT_TEAM=$KEYCHAIN_TEAM_ID
        echo "Team ID obtido do Keychain: $DEVELOPMENT_TEAM"
    fi
    
    # Tentar obter o Team ID do git config como alternativa
    GIT_TEAM_ID=$(git config --get user.teamid 2>/dev/null)
    if [ -n "$GIT_TEAM_ID" ]; then
        DEVELOPMENT_TEAM=$GIT_TEAM_ID
        echo "Team ID obtido do git config: $DEVELOPMENT_TEAM"
    fi
    
    # Tentar obter o Team ID do fastlane
    if [ -f "$PROJECT_PATH/../../fastlane/Appfile" ]; then
        FASTLANE_TEAM_ID=$(grep -E 'team_id\s*\(' "$PROJECT_PATH/../../fastlane/Appfile" | sed -E 's/.*team_id\s*\(\s*"([^"]+)".*/\1/')
        if [ -n "$FASTLANE_TEAM_ID" ]; then
            DEVELOPMENT_TEAM=$FASTLANE_TEAM_ID
            echo "Team ID obtido do Appfile: $DEVELOPMENT_TEAM"
        fi
    fi
fi

# Definir os nomes dos perfis de provisionamento com base no bundle ID do projeto
APP_BUNDLE_IDS=()

# Tentar obter o bundle ID do project.yml
if [ -n "$YML_FILES" ]; then
    for yml_file in $YML_FILES; do
        BUNDLE_ID=$(grep -E 'bundleId:' "$yml_file" | head -1 | sed -E 's/.*bundleId:\s*"([^"]+)".*/\1/')
        if [ -n "$BUNDLE_ID" ]; then
            APP_BUNDLE_IDS+=("$BUNDLE_ID")
        fi
    done
fi

# Tentar obter o bundle ID dos arquivos Tuist
if [ -n "$TUIST_PROJECT_FILES" ] || [ -n "$TUIST_TARGETS_FILES" ]; then
    for tuist_file in $TUIST_PROJECT_FILES $TUIST_TARGETS_FILES; do
        BUNDLE_ID=$(grep -E 'bundleId\s*:\s*"' "$tuist_file" | head -1 | sed -E 's/.*bundleId\s*:\s*"([^"]+)".*/\1/')
        if [ -n "$BUNDLE_ID" ]; then
            APP_BUNDLE_IDS+=("$BUNDLE_ID")
        fi
    done
fi

# Se não conseguiu detectar nenhum bundle ID, use o nome do projeto como fallback
if [ ${#APP_BUNDLE_IDS[@]} -eq 0 ]; then
    DEFAULT_BUNDLE_ID="br.com.joao.gabriel.$PROJECT_NAME"
    APP_BUNDLE_IDS+=("$DEFAULT_BUNDLE_ID")
    echo "Aviso: Nenhum bundle ID detectado. Usando ID padrão: $DEFAULT_BUNDLE_ID"
fi

# Usar o primeiro bundle ID para os perfis de provisionamento
PRIMARY_BUNDLE_ID=${APP_BUNDLE_IDS[0]}
PROVISIONING_PROFILE_NAME="match Development $PRIMARY_BUNDLE_ID"
PROVISIONING_PROFILE_DISTRIBUTION="match AppStore $PRIMARY_BUNDLE_ID"

echo "Bundle IDs detectados: ${APP_BUNDLE_IDS[*]}"
echo "Usando para perfis de provisionamento: $PRIMARY_BUNDLE_ID"
echo "Perfil de desenvolvimento: $PROVISIONING_PROFILE_NAME"
echo "Perfil de distribuição: $PROVISIONING_PROFILE_DISTRIBUTION"

# Contador para saber se algum arquivo foi processado
FILES_PROCESSED=0

# Processa arquivos project.yml (XcodeGen)
if [ -n "$YML_FILES" ]; then
    for yml_file in $YML_FILES; do
        echo "Atualizando configurações em $yml_file (XcodeGen)"
        
        # Verifica se o arquivo já contém as configurações de assinatura
        if grep -q "DEVELOPMENT_TEAM:" "$yml_file"; then
            # Substituir configurações existentes
            sed -i '' "s/DEVELOPMENT_TEAM: .*/DEVELOPMENT_TEAM: $DEVELOPMENT_TEAM/" "$yml_file"
        else
            # Adicionar configurações se não existirem
            echo "Adicionando configurações de assinatura ao arquivo XcodeGen"
            # Encontrar a seção settings para adicionar as configurações
            if grep -q "settings:" "$yml_file"; then
                # Adicionar após a linha settings:
                sed -i '' '/settings:/a\
    DEVELOPMENT_TEAM: '"$DEVELOPMENT_TEAM"'\
    CODE_SIGN_IDENTITY: "'"$CODE_SIGN_IDENTITY"'"\
    PROVISIONING_PROFILE_SPECIFIER: "'"$PROVISIONING_PROFILE_NAME"'"' "$yml_file"
            else
                # Adicionar ao final do arquivo se não encontrar a seção settings
                echo "settings:
    DEVELOPMENT_TEAM: $DEVELOPMENT_TEAM
    CODE_SIGN_IDENTITY: \"$CODE_SIGN_IDENTITY\"
    PROVISIONING_PROFILE_SPECIFIER: \"$PROVISIONING_PROFILE_NAME\"" >> "$yml_file"
            fi
        fi
        
        echo "✅ Configuração XcodeGen concluída para $yml_file"
        FILES_PROCESSED=$((FILES_PROCESSED+1))
    done
fi

# Processa arquivos Project.swift (Tuist)
if [ -n "$TUIST_PROJECT_FILES" ]; then
    for tuist_file in $TUIST_PROJECT_FILES; do
        echo "Atualizando configurações em $tuist_file (Tuist)"
        
        # Salva uma cópia de backup do arquivo
        cp "$tuist_file" "$tuist_file.bak"
        
        # Verifica se o arquivo já contém configurações de assinatura
        HAS_TEAM_ID=$(grep -c "teamId:" "$tuist_file" || true)
        
        if [ "$HAS_TEAM_ID" -gt 0 ]; then
            # Substituir configuração existente
            sed -i '' "s/teamId: \".*\"/teamId: \"$DEVELOPMENT_TEAM\"/" "$tuist_file"
        else
            # Adicionar configuração de teamId ao arquivo
            # Normalmente, isto deve ser adicionado na seção Project ou settings
            echo "Adicionando teamId ao arquivo Project.swift"
            
            # Se encontrar a linha settings:, adicionar após ela
            if grep -q "settings: .settings" "$tuist_file"; then
                sed -i '' '/settings: .settings/a\
        teamId: "'"$DEVELOPMENT_TEAM"'",' "$tuist_file"
            # Se encontrar a linha name:, adicionar após ela
            elif grep -q "name: " "$tuist_file"; then
                sed -i '' '/name: /a\
    organizationName: "'"$PROJECT_NAME"'",\
    options: .options(),\
    settings: .settings(\
        base: [\
            "DEVELOPMENT_TEAM": "'"$DEVELOPMENT_TEAM"'",\
            "CODE_SIGN_IDENTITY": "'"$CODE_SIGN_IDENTITY"'",\
            "PROVISIONING_PROFILE_SPECIFIER": "'"$PROVISIONING_PROFILE_NAME"'"\
        ]\
    ),' "$tuist_file"
            fi
        fi
        
        # Procura por cada target para adicionar as configurações
        # Encontrar linhas com Target.target
        grep -n "Target.target" "$tuist_file" | while read -r line; do
            lineno=$(echo "$line" | cut -d ':' -f 1)
            
            # Continuar procurando no arquivo até encontrar a linha de fechamento do target
            current_line=$lineno
            inside_target=true
            
            while [ "$inside_target" = true ] && [ "$current_line" -lt $(wc -l < "$tuist_file") ]; do
                current_line=$((current_line + 1))
                
                # Se encontrar uma linha com settings:, adicionar as configurações lá
                if grep -q "settings:" "$(sed -n "${current_line}p" "$tuist_file")"; then
                    sed -i '' "${current_line}s/settings:.*/settings: .settings(\
                base: [\
                    \"DEVELOPMENT_TEAM\": \"$DEVELOPMENT_TEAM\",\
                    \"CODE_SIGN_IDENTITY\": \"$CODE_SIGN_IDENTITY\",\
                    \"PROVISIONING_PROFILE_SPECIFIER\": \"$PROVISIONING_PROFILE_NAME\"\
                ]),/" "$tuist_file"
                    break
                fi
                
                # Se encontrar o final do target (fechamento de parêntese), adicionar settings ali
                if grep -q ")" "$(sed -n "${current_line}p" "$tuist_file")" && ! grep -q "(" "$(sed -n "${current_line}p" "$tuist_file")"; then
                    sed -i '' "${current_line}i\\
            settings: .settings(\
                base: [\
                    \"DEVELOPMENT_TEAM\": \"$DEVELOPMENT_TEAM\",\
                    \"CODE_SIGN_IDENTITY\": \"$CODE_SIGN_IDENTITY\",\
                    \"PROVISIONING_PROFILE_SPECIFIER\": \"$PROVISIONING_PROFILE_NAME\"\
                ]\
            )" "$tuist_file"
                    break
                fi
            done
        done
        
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
