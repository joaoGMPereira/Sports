#!/usr/bin/swift

import Foundation

// MARK: - Descoberta de componentes disponíveis

let componentConfiguration = ComponentConfiguration()
let generateComponent = GenerateComponent()

func findAvailableComponents() -> [String] {
    var components: [String] = []
    
    // 1. Procurar componentes nativos
    components.append(contentsOf: Array(NATIVE_COMPONENTS.keys).sorted())
    
    // 2. Procurar componentes customizados
    do {
        // BaseElements/Natives
        if let entries = try? FileManager.default.contentsOfDirectory(atPath: "\(COMPONENTS_PATH)/BaseElements/Natives") {
            for entry in entries {
                if !entry.hasPrefix(".") && !components.contains(entry) {
                    components.append(entry)
                }
            }
        }
        
        // Components/Customs
        if let entries = try? FileManager.default.contentsOfDirectory(atPath: "\(COMPONENTS_PATH)/Components/Customs") {
            for entry in entries {
                if !entry.hasPrefix(".") && !components.contains(entry) {
                    components.append(entry)
                }
            }
        }
    }
    
    return components.sorted()
}

// MARK: - Modelos de componentes nativos

struct NativeComponentParameter {
    let label: String?
    let name: String
    let type: String
    let defaultValue: String?
    let isAction: Bool
}

struct NativeComponent {
    let typePath: String
    let defaultContent: String?
    let defaultStyleCase: String
    let initParams: [NativeComponentParameter]
    let exampleCode: String
}

let NATIVE_COMPONENTS: [String: NativeComponent] = [
    "Button": NativeComponent(
        typePath: "BaseElements/Natives",
        defaultContent: "Button",
        defaultStyleCase: "contentA",
        initParams: [
            NativeComponentParameter(label: nil, name: "title", type: "String", defaultValue: nil, isAction: false),
            NativeComponentParameter(label: nil, name: "action", type: "() -> Void", defaultValue: nil, isAction: true)
        ],
        exampleCode: """
        Button("Exemplo") {
            // Ação do botão
        }
        .buttonStyle(.contentA())
        """
    ),
    "Text": NativeComponent(
        typePath: "BaseElements/Natives",
        defaultContent: "Text",
        defaultStyleCase: "smallContentA",
        initParams: [
            NativeComponentParameter(label: nil, name: "content", type: "String", defaultValue: nil, isAction: false)
        ],
        exampleCode: """
        Text("Exemplo de texto")
            .textStyle(.small(.contentA))
        """
    ),
    "Divider": NativeComponent(
        typePath: "BaseElements/Natives",
        defaultContent: nil,
        defaultStyleCase: "contentA",
        initParams: [],
        exampleCode: """
        Divider()
            .dividerStyle(.contentA())
        """
    ),
    "Toggle": NativeComponent(
        typePath: "BaseElements/Natives",
        defaultContent: "Toggle",
        defaultStyleCase: "mediumHighlightA",
        initParams: [
            NativeComponentParameter(label: nil, name: "isOn", type: "Binding<Bool>", defaultValue: nil, isAction: false),
            NativeComponentParameter(label: nil, name: "label", type: "String", defaultValue: nil, isAction: false)
        ],
        exampleCode: """
        Toggle("Exemplo de Toggle", isOn: $isEnabled)
            .toggleStyle(.default(.highlightA))
        """
    ),
    "TextField": NativeComponent(
        typePath: "BaseElements/Natives",
        defaultContent: "TextField",
        defaultStyleCase: "contentA",
        initParams: [
            NativeComponentParameter(label: nil, name: "text", type: "Binding<String>", defaultValue: nil, isAction: false),
            NativeComponentParameter(label: nil, name: "placeholder", type: "String", defaultValue: nil, isAction: false)
        ],
        exampleCode: """
        TextField("Placeholder", text: $textValue)
            .textFieldStyle(.contentA())
        """
    )
]

func createSampleFile(for componentName: String) -> Bool {
    Log.log("Criando amostra para o componente: \(componentName)")
    
    // Procurar informações do componente
    guard let componentInfo = componentConfiguration.findComponentFiles(componentName) else {
        Log.log("Não foi possível encontrar o componente: \(componentName)", level: .error)
        return false
    }
    
    // Determinar o caminho para salvar o arquivo Sample
    let samplePath = "\(SAMPLES_PATH)/\(componentInfo.typePath)/\(componentName)"
    
    // Criar os diretórios, se necessário
    do {
        try FileManager.default.createDirectory(atPath: samplePath, withIntermediateDirectories: true)
    } catch {
        Log.log("Erro ao criar diretórios: \(error)", level: .error)
        return false
    }
    
    // Gerar o conteúdo do arquivo Sample
    var sampleContent: String
    
    if componentInfo.isNative {
        sampleContent = generateComponent.generateNativeComponentSample(componentInfo)
    } else {
        // Esta parte implementaria o método generateSampleFile, que é mais complexo
        // Para simplificar, podemos usar o mesmo método para componentes nativos por enquanto
        sampleContent = generateComponent.generateNativeComponentSample(componentInfo)
    }
    
    // Salvar o arquivo
    let sampleFilePath = "\(samplePath)/\(componentName)Sample.swift"
    do {
        try sampleContent.write(toFile: sampleFilePath, atomically: true, encoding: .utf8)
        Log.log("Arquivo Sample criado com sucesso: \(sampleFilePath)")
        
        // Formatar o arquivo gerado usando swiftformat
        formatSwiftFile(sampleFilePath)
        
        return true
    } catch {
        Log.log("Erro ao criar o arquivo Sample: \(error)", level: .error)
        return false
    }
}

// MARK: - Formatação de código Swift

func formatSwiftFile(_ filePath: String) {
    Log.log("Formatando o arquivo: \(filePath)")
    
    // Usar a classe SwiftFormatter para formatar o arquivo
    let formatter = SwiftFormatter(logger: { message, level in
        Log.log(message, level: level)
    })
    
    let result = formatter.formatFile(at: filePath)
    
    switch result {
    case .success(let message):
        Log.log(message, level: .info)
    case .failure(let error):
        Log.log(error, level: .warning)
        Log.log("Use Command+A seguido de Control+I no Xcode para formatar o arquivo manualmente.", level: .warning)
    }
}

// MARK: - Menu Principal e Interface de Usuário


// MARK: - Main

// Se executado com argumentos, usar modo de linha de comando
// Senão, iniciar interface interativa
if CommandLine.arguments.count > 1 {
    let componentName = CommandLine.arguments[1]
    let success = createSampleFile(for: componentName)
    exit(success ? 0 : 1)
} else {
    // Iniciar interface interativa
    let interactionMenu = InteractionMenu()
    interactionMenu.mainMenu {
        exit(0)
    }
}
