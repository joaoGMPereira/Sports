
#!/usr/local/bin/bash

generateWorkspace() {
    # Caminho para o diretório do monorepo
    MONOREPO_DIR=$(pwd)

    # Criar um workspace e adicionar os projetos
    WORKSPACE_PATH="$MONOREPO_DIR/App.xcworkspace"
    echo "Criando workspace em $WORKSPACE_PATH"

    # Remover workspace existente
    rm -rf "$WORKSPACE_PATH"

    # Criar novo workspace
    mkdir -p "$WORKSPACE_PATH"

    # Verificar se `contents.xcworkspacedata` é um diretório e removê-lo
    if [[ -d "$WORKSPACE_PATH/contents.xcworkspacedata" ]]; then
        rm -rf "$WORKSPACE_PATH/contents.xcworkspacedata"
    fi

    # Criar o arquivo `contents.xcworkspacedata` (agora garantindo que não seja um diretório)
    cat > "$WORKSPACE_PATH/contents.xcworkspacedata" <<EOL
<?xml version="1.0" encoding="UTF-8"?>
<Workspace
   version = "1.0">
</Workspace>
EOL

    echo "Workspace criado com sucesso."
}

openWorkspace() {
    workspace='<?xml version="1.0" encoding="UTF-8"?>
<Workspace
    version = "1.0">'
}

closeWorkspace() {
    workspace+='
</Workspace>'
}

openGroup() {
    local groupName=$1
    workspace+="
    <Group
        location = \"container:\"
        name = \"$groupName\">"
}

closeGroup() {
    workspace+="
    </Group>"
}

addFileRef() {
    local fileRef=$1
    workspace+="
        <FileRef
            location = \"group:$fileRef.xcodeproj\">
        </FileRef>"
}

generateTargetsGroup() {
    openGroup "Targets"
    addFileRef "KettleGym/KettleGym"
    closeGroup
}

generatePackagesGroups() {
    for categoryPath in Packages/*; do
        if [[ -d "$categoryPath" ]]; then
            categoryName=$(basename "$categoryPath")
            projectPath="$categoryPath"
            if [[ -d "$projectPath" && -f "$projectPath/project.yml" ]]; then
                openGroup "$categoryName"
                addFileRef "$projectPath/$categoryName"
                closeGroup
            else
                echo "⚠️ Aviso: O módulo '$categoryName' não possui um .xcodeproj ainda. '$projectPath'"
            fi
        fi
    done
}

generateWorkspaceData() {
    generateWorkspace
    openWorkspace
    generateTargetsGroup
    generatePackagesGroups
    closeWorkspace

    echo "$workspace" > ./App.xcworkspace/contents.xcworkspacedata
}

generateWorkspaceData
