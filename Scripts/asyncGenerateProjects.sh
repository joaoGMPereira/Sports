#!/bin/sh

set -e

source Scripts/envVariables.sh

echo "🔄 Iniciando geração assíncrona dos projetos dos módulos..."

# Encontra todos os arquivos project.yml dentro de Packages, independentemente da profundidade
project_files=$(find Packages -type f -name "project.yml")

pids=()
for project_file in $project_files; do
    dir=$(dirname "$project_file")
    echo "🚀 Encontrado project.yml em: $project_file"
    echo "📂 Diretório: $dir"

    # Executa xcodegen e redireciona a saída para logs
    xcodegen -s "$project_file" > "$dir/xcodegen_output.log" 2>&1 &
    pid=$!
    pids+=($pid)
    echo "✅ Processo iniciado para $project_file (PID: $pid) - Logs em $dir/xcodegen_output.log"
done

echo "⏳ Aguardando a finalização de todos os processos..."

# Aguardar todos os processos finalizarem
for pid in "${pids[@]}"; do
    if ps -p $pid > /dev/null; then
        echo "🕒 Aguardando processo (PID: $pid)..."
        if wait $pid; then
            echo "✅ Processo (PID: $pid) finalizado com sucesso."
        else
            echo "❌ Erro durante a execução do processo (PID: $pid). Veja os logs acima para detalhes."
        fi
    else
        echo "⚠️ Processo (PID: $pid) não encontrado, pode ter finalizado anteriormente."
    fi
done

echo "🎉 Geração assíncrona dos módulos concluída."

# Agora gerar os projetos principais que referenciam todos os módulos

echo "\n🏗️ Iniciando geração dos projetos principais..."

if [ -f "KettleGym/project.yml" ]; then
    echo "🚀 Gerando projeto principal: KettleGym/project.yml"
    if xcodegen -s KettleGym/project.yml | tee KettleGym/xcodegen_output.log; then
        echo "✅ Projeto principal gerado com sucesso. Logs disponíveis em KettleGym/xcodegen_output.log"
    else
        echo "❌ Erro ao gerar o projeto principal. Verifique os logs em KettleGym/xcodegen_output.log"
    fi
else
    echo "⚠️ Arquivo KettleGym/project.yml não encontrado."
fi

echo "✅ Processo de geração finalizado."
