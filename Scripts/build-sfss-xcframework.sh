#!/bin/bash

# Script para gerar XCFramework para SFSafeSymbols
# Versão simplificada que utiliza o esquema SFSafeSymbols-Package

# Configurações
TEMP_DIR="$HOME/sfss_build"
REPO_URL="https://github.com/SFSafeSymbols/SFSafeSymbols.git"
FRAMEWORK_NAME="SFSafeSymbols"
FINAL_OUTPUT_PATH="$HOME/KettleGym/Frameworks"
SCHEME_NAME="SFSafeSymbols-Package"

# Limpar e criar diretórios
echo "🧹 Limpando diretórios anteriores..."
rm -rf "$TEMP_DIR"
mkdir -p "$TEMP_DIR"
mkdir -p "$FINAL_OUTPUT_PATH"

echo "📥 Clonando o repositório SFSafeSymbols..."
git clone "$REPO_URL" "$TEMP_DIR/repo"
cd "$TEMP_DIR/repo"

# Método alternativo utilizando diretamente o comando xcodebuild
echo "🔨 Criando projeto do Xcode..."
mkdir -p build

# Construir a biblioteca para iOS
echo "📱 Compilando para iOS..."
xcodebuild archive \
    -scheme "$SCHEME_NAME" \
    -destination "generic/platform=iOS" \
    -archivePath "$TEMP_DIR/ios.xcarchive" \
    -derivedDataPath "$TEMP_DIR/DerivedData" \
    SKIP_INSTALL=NO \
    BUILD_LIBRARY_FOR_DISTRIBUTION=YES

# Construir a biblioteca para iOS Simulator
echo "📱 Compilando para iOS Simulator..."
xcodebuild archive \
    -scheme "$SCHEME_NAME" \
    -destination "generic/platform=iOS Simulator" \
    -archivePath "$TEMP_DIR/iossimulator.xcarchive" \
    -derivedDataPath "$TEMP_DIR/DerivedData" \
    SKIP_INSTALL=NO \
    BUILD_LIBRARY_FOR_DISTRIBUTION=YES

# Construir a biblioteca para macOS
echo "🖥️ Compilando para macOS..."
xcodebuild archive \
    -scheme "$SCHEME_NAME" \
    -destination "generic/platform=macOS" \
    -archivePath "$TEMP_DIR/macos.xcarchive" \
    -derivedDataPath "$TEMP_DIR/DerivedData" \
    SKIP_INSTALL=NO \
    BUILD_LIBRARY_FOR_DISTRIBUTION=YES

# Obter caminhos para os frameworks
echo "🔍 Procurando frameworks compilados..."
find "$TEMP_DIR" -name "$FRAMEWORK_NAME.framework" -type d

# Localizar os frameworks
IOS_FRAMEWORK=$(find "$TEMP_DIR/ios.xcarchive" -name "$FRAMEWORK_NAME.framework" -type d | head -n 1)
SIMULATOR_FRAMEWORK=$(find "$TEMP_DIR/iossimulator.xcarchive" -name "$FRAMEWORK_NAME.framework" -type d | head -n 1)
MACOS_FRAMEWORK=$(find "$TEMP_DIR/macos.xcarchive" -name "$FRAMEWORK_NAME.framework" -type d | head -n 1)

# Verificar se encontramos pelo menos um framework
if [ -z "$IOS_FRAMEWORK" ] && [ -z "$SIMULATOR_FRAMEWORK" ] && [ -z "$MACOS_FRAMEWORK" ]; then
    echo "❌ Nenhum framework encontrado. Verificando diretório de DerivedData..."
    
    # Procurar em DerivedData
    find "$TEMP_DIR/DerivedData" -name "$FRAMEWORK_NAME.framework" -type d
    
    # Tentar outra abordagem: usar a ferramenta swift-create-xcframework
    echo "🔄 Tentando utilizar uma abordagem alternativa..."
    
    # Usar a ferramenta swift build
    echo "🔨 Compilando usando swift build..."
    swift build -c release
    
    # Verificar a saída da compilação
    find .build -name "$FRAMEWORK_NAME.framework" -type d
    
    # Tentar criação direta com o comando xcframework
    echo "❌ Não foi possível compilar o framework. Saindo..."
    exit 1
fi

# Construir o comando para criar o XCFramework
XCFRAMEWORK_CMD="xcodebuild -create-xcframework"

# Adicionar frameworks encontrados ao comando
if [ -n "$IOS_FRAMEWORK" ]; then
    echo "✅ Framework iOS encontrado: $IOS_FRAMEWORK"
    XCFRAMEWORK_CMD="$XCFRAMEWORK_CMD -framework $IOS_FRAMEWORK"
fi

if [ -n "$SIMULATOR_FRAMEWORK" ]; then
    echo "✅ Framework iOS Simulator encontrado: $SIMULATOR_FRAMEWORK"
    XCFRAMEWORK_CMD="$XCFRAMEWORK_CMD -framework $SIMULATOR_FRAMEWORK"
fi

if [ -n "$MACOS_FRAMEWORK" ]; then
    echo "✅ Framework macOS encontrado: $MACOS_FRAMEWORK"
    XCFRAMEWORK_CMD="$XCFRAMEWORK_CMD -framework $MACOS_FRAMEWORK"
fi

# Adicionar o caminho de saída
XCFRAMEWORK_PATH="$TEMP_DIR/$FRAMEWORK_NAME.xcframework"
XCFRAMEWORK_CMD="$XCFRAMEWORK_CMD -output $XCFRAMEWORK_PATH"

# Executar o comando
echo "🚀 Criando XCFramework com o comando: $XCFRAMEWORK_CMD"
eval $XCFRAMEWORK_CMD

# Verificar se o XCFramework foi criado
if [ -d "$XCFRAMEWORK_PATH" ]; then
    # Copiar para o diretório final
    cp -R "$XCFRAMEWORK_PATH" "$FINAL_OUTPUT_PATH/"
    
    echo "✅ XCFramework criado com sucesso em: $FINAL_OUTPUT_PATH/$FRAMEWORK_NAME.xcframework"
    echo "🧹 Limpando arquivos temporários..."
    # rm -rf "$TEMP_DIR"  # Comentado para debug
    echo "✨ Concluído!"
else
    echo "❌ Falha ao criar o XCFramework."
    
    # Último recurso: Usar carthage
    echo "🔄 Tentando último recurso: usar Carthage..."
    
    # Verificar se o Carthage está instalado
    if command -v carthage &> /dev/null; then
        echo "✅ Carthage encontrado. Tentando compilar com carthage..."
        
        # Criar um Cartfile
        echo 'github "SFSafeSymbols/SFSafeSymbols"' > Cartfile
        
        # Rodar carthage
        carthage build --no-skip-current --use-xcframeworks
        
        # Verificar se foi gerado o framework
        if [ -d "Carthage/Build/$FRAMEWORK_NAME.xcframework" ]; then
            cp -R "Carthage/Build/$FRAMEWORK_NAME.xcframework" "$FINAL_OUTPUT_PATH/"
            echo "✅ XCFramework criado com sucesso usando Carthage em: $FINAL_OUTPUT_PATH/$FRAMEWORK_NAME.xcframework"
            exit 0
        else
            echo "❌ Falha ao criar XCFramework com Carthage."
        fi
    else
        echo "❌ Carthage não está instalado. Não foi possível criar o XCFramework."
    fi
    
    exit 1
fi