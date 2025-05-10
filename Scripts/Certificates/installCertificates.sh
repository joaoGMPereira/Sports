#!/bin/bash

echo "==== Instalando e configurando certificados para todos os projetos ===="

# Configura o diretório raiz do monorepo logo no início
MONOREPO_ROOT="/Users/ipereira.mazzatech/KettleGym"

# Função para baixar certificados
download_certificates() {
    echo "Baixando certificados usando fastlane match..."
    
    # Tenta executar fastlane via bundle exec
    bundle exec fastlane setup_certificates_dev
    if [ $? -ne 0 ]; then
        echo "Erro ao baixar certificados via bundle. Tentando executar fastlane diretamente..."
        fastlane match_certificates
        if [ $? -ne 0 ]; then
            echo "Erro ao baixar certificados."
            echo "Por favor, execute manualmente: 'fastlane match_certificates'"
            echo "E depois execute este script novamente com a opção -s para pular o download dos certificados:"
            echo "./Scripts/Certificates/installCertificates.sh -s"
            exit 1
        fi
    fi
}

# Verificar parâmetros
SKIP_CERT_DOWNLOAD=false
while getopts "s" opt; do
  case $opt in
    s) SKIP_CERT_DOWNLOAD=true ;;
    *) echo "Uso: $0 [-s]"; exit 1 ;;
  esac
done

# Baixa os certificados usando fastlane match (a menos que seja para pular)
if [ "$SKIP_CERT_DOWNLOAD" = false ]; then
    download_certificates
else
    echo "Pulando download de certificados conforme solicitado..."
fi

# Encontra todos os arquivos project.yml no monorepo
echo "Procurando por projetos no monorepo..."

# Lista de todos os project.yml encontrados
yml_files=$(find "$MONOREPO_ROOT" -name "project.yml" -type f 2>/dev/null)

# Lista de todos os Project.swift encontrados
tuist_project_files=$(find "$MONOREPO_ROOT" -name "Project.swift" -type f 2>/dev/null)
echo "Tuist Files $tuist_project_files"

# Processa cada arquivo project.yml encontrado
for yml_file in $yml_files; do
    project_dir=$(dirname "$yml_file")
    project_name=$(basename "$project_dir")
    
    echo "Encontrado projeto ($project_name) em: $project_dir"
    
    # Encontra arquivos Tuist relacionados ao mesmo projeto
    related_project_swift=$(find "$project_dir" -name "Project.swift" -type f 2>/dev/null)
    related_targets_swift=$(find "$project_dir" -name "Targets.swift" -type f 2>/dev/null)
    related_config_swift=$(find "$project_dir" -name "Config.swift" -type f -path "*/Tuist/ProjectDescriptionHelpers/*" 2>/dev/null)
    
    echo "Configurando certificados para o projeto $project_name..."
    
    # Chama o script configProjects.sh para este projeto
    ./Scripts/Certificates/configProjects.sh "$project_name" "$project_dir" "$yml_file" "$related_project_swift" "$related_targets_swift" "$related_config_swift"
    
    echo "  ✅ Certificados configurados para $project_name"
done

# Processa cada arquivo Project.swift que não tenha um project.yml correspondente
for tuist_file in $tuist_project_files; do
    project_dir=$(dirname "$tuist_file")
    project_name=$(basename "$project_dir")
    
    # Verifica se este projeto já foi processado na etapa anterior (se tem project.yml)
    yml_exists=$(find "$project_dir" -name "project.yml" -type f -maxdepth 1 2>/dev/null)
    if [ -n "$yml_exists" ]; then
        # Este projeto já foi processado na etapa anterior, pule
        echo "Projeto $project_name já processado anteriormente, pulando..."
        continue
    fi
    
    # Encontra outros arquivos Tuist relacionados
    related_targets_swift=$(find "$project_dir" -name "Targets.swift" -type f 2>/dev/null)
    related_config_swift=$(find "$project_dir" -name "Config.swift" -type f -path "*/Tuist/ProjectDescriptionHelpers/*" 2>/dev/null)
    
    echo "Configurando certificados para o projeto Tuist $project_name..."
    
    # Chama o script configProjects.sh para este projeto
    ./Scripts/Certificates/configProjects.sh "$project_name" "$project_dir" "" "$tuist_file" "$related_targets_swift" "$related_config_swift"
    
    echo "  ✅ Certificados configurados para $project_name"
done

echo "==== Configuração de certificados concluída ===="
