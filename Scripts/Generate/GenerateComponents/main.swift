#!/usr/bin/swift

import Foundation

/**
 Script para gerar arquivos Sample para componentes do Zenith
 Este script analisa arquivos View, Configuration e Styles de um componente
 e gera automaticamente um arquivo Sample para demonstrar o uso do componente.
 */

// MARK: - Constantes e configurações

let homeDir = FileManager.default.homeDirectoryForCurrentUser.path
let ZENITH_PATH = "\(homeDir)/KettleGym/Packages/Zenith"
let ZENITH_SAMPLE_PATH = "\(homeDir)/KettleGym/Packages/ZenithSample"
let COMPONENTS_PATH = "\(ZENITH_PATH)/Sources/Zenith"
let SAMPLES_PATH = "\(ZENITH_SAMPLE_PATH)/ZenithSample"
let TESTS_PATH = "\(ZENITH_PATH)/Tests/ZenithTests"

let INDENT_SIZE = 4
let GENERATE_TESTS = false // Por padrão, não gera testes

// Detectar se estamos executando em modo debug no Xcode
// Isso permitirá desabilitar os códigos de cores ANSI que não funcionam no console do Xcode
#if DEBUG
let IS_RUNNING_IN_XCODE = true
#else
let IS_RUNNING_IN_XCODE = ProcessInfo.processInfo.environment["XPC_SERVICE_NAME"]?.contains("com.apple.dt.Xcode") ?? false
#endif

// MARK: - Logging

enum LogLevel {
    case info, warning, error
}

func log(_ message: String, level: LogLevel = .info) {
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
    let timestamp = dateFormatter.string(from: Date())
    
    let prefix: String
    if IS_RUNNING_IN_XCODE {
        // Usar versão sem cores para o Xcode
        switch level {
        case .info:
            prefix = "INFO"
        case .warning:
            prefix = "WARNING"
        case .error:
            prefix = "ERROR"
        }
    } else {
        // Usar versão colorida para terminal
        switch level {
        case .info:
            prefix = "\u{001B}[32mINFO\u{001B}[0m" // Verde
        case .warning:
            prefix = "\u{001B}[33mWARNING\u{001B}[0m" // Amarelo
        case .error:
            prefix = "\u{001B}[31mERROR\u{001B}[0m" // Vermelho
        }
    }
    
    print("\(timestamp) - \(prefix) - \(message)")
}

// MARK: - UI e Interação com Usuário

struct ConsoleUI {
    // ANSI Color Codes - serão usados apenas quando não estiver no Xcode
    static let reset = IS_RUNNING_IN_XCODE ? "" : "\u{001B}[0m"
    static let bold = IS_RUNNING_IN_XCODE ? "" : "\u{001B}[1m"
    static let red = IS_RUNNING_IN_XCODE ? "" : "\u{001B}[31m"
    static let green = IS_RUNNING_IN_XCODE ? "" : "\u{001B}[32m"
    static let yellow = IS_RUNNING_IN_XCODE ? "" : "\u{001B}[33m"
    static let blue = IS_RUNNING_IN_XCODE ? "" : "\u{001B}[34m"
    static let magenta = IS_RUNNING_IN_XCODE ? "" : "\u{001B}[35m"
    static let cyan = IS_RUNNING_IN_XCODE ? "" : "\u{001B}[36m"
    
    static func printTitle(_ title: String) {
        let line = String(repeating: "=", count: title.count + 4)
        print("\n\(bold)\(blue)\(line)\(reset)")
        print("\(bold)\(blue)| \(title) |\(reset)")
        print("\(bold)\(blue)\(line)\(reset)\n")
    }
    
    static func printOption(_ index: Int, _ text: String) {
        print("\(yellow)[\(index)]\(reset) \(text)")
    }
    
    static func printSuccess(_ message: String) {
        print("\(green)✓ \(message)\(reset)")
    }
    
    static func printError(_ message: String) {
        print("\(red)✗ \(message)\(reset)")
    }
    
    static func printInfo(_ message: String) {
        print("\(cyan)ℹ \(message)\(reset)")
    }
    
    static func promptForInput(_ prompt: String) -> String {
        print("\(prompt): ", terminator: "")
        return readLine() ?? ""
    }
    
    static func promptForChoice(_ prompt: String, options: [String]) -> Int {
        print(prompt)
        for (index, option) in options.enumerated() {
            printOption(index + 1, option)
        }
        
        while true {
            let input = promptForInput("Escolha uma opção (1-\(options.count))")
            if let choice = Int(input), choice >= 1, choice <= options.count {
                return choice
            }
            printError("Opção inválida. Tente novamente.")
        }
    }
}

func clearConsole() {
    // ANSI escape code para limpar a tela
    print("\u{001B}[2J\u{001B}[H", terminator: "")
}

func pauseForAction() {
    print("\nPressione ENTER para continuar...", terminator: "")
    _ = readLine()
}

// MARK: - Descoberta de componentes disponíveis

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

// MARK: - Modelos de dados

struct SwiftProperty {
    let type: String // var ou let
    let name: String
    let dataType: String
    let defaultValue: String?
}

struct StyleFunction {
    let name: String
    let paramName: String
    let paramType: String
}

struct InitParameter {
    let label: String?
    let name: String
    let type: String
    let defaultValue: String?
    let isAction: Bool
}

class ComponentInfo {
    let name: String
    let typePath: String
    
    var viewPath: String = ""
    var configPath: String = ""
    var stylesPath: String = ""
    
    var properties: [SwiftProperty] = []
    var styleCases: [String] = []
    var styleFunctions: [StyleFunction] = []
    
    var enumProperties: [SwiftProperty] = []
    var textProperties: [SwiftProperty] = []
    var boolProperties: [SwiftProperty] = []
    var numberProperties: [SwiftProperty] = []
    var closureProperties: [SwiftProperty] = []
    var complexProperties: [SwiftProperty] = []
    
    var publicInitParams: [InitParameter] = []
    var hasActionParam: Bool = false
    var isNative: Bool = false
    var exampleCode: String = ""
    
    init(name: String, typePath: String) {
        self.name = name
        self.typePath = typePath
    }
    
    func getPropertyByName(_ name: String) -> SwiftProperty? {
        return properties.first { $0.name == name }
    }
}

// MARK: - Funções utilitárias

func readFile(at path: String) -> String? {
    do {
        return try String(contentsOfFile: path, encoding: .utf8)
    } catch {
        log("Erro ao ler o arquivo \(path): \(error)", level: .error)
        return nil
    }
}

// MARK: - Análise de código Swift (Parser)

func extractProperties(from content: String) -> [SwiftProperty] {
    var properties: [SwiftProperty] = []
    
    // Padrão para localizar propriedades
    let pattern = "(var|let)\\s+(\\w+)\\s*:\\s*([^{=\\n]+)(?:\\s*=\\s*([^{\\n]+))?"
    let regex = try! NSRegularExpression(pattern: pattern, options: [])
    let matches = regex.matches(in: content, options: [], range: NSRange(content.startIndex..., in: content))
    
    for match in matches {
        guard let propTypeRange = Range(match.range(at: 1), in: content),
              let propNameRange = Range(match.range(at: 2), in: content),
              let propDataTypeRange = Range(match.range(at: 3), in: content) else {
            continue
        }
        
        let propType = String(content[propTypeRange])
        let propName = String(content[propNameRange])
        let propDataType = String(content[propDataTypeRange]).trimmingCharacters(in: .whitespaces)
        
        var defaultValue: String? = nil
        if match.numberOfRanges > 4, let defaultValueRange = Range(match.range(at: 4), in: content) {
            defaultValue = String(content[defaultValueRange]).trimmingCharacters(in: .whitespaces)
        }
        
        properties.append(SwiftProperty(
            type: propType,
            name: propName,
            dataType: propDataType,
            defaultValue: defaultValue
        ))
    }
    
    return properties
}

func extractStyleFunctions(from content: String, componentName: String) -> [StyleFunction] {
    var styleFunctions: [StyleFunction] = []
    
    // Procura por extensões como: public extension TextStyle where Self == BaseTextStyle
    let extensionPattern = "public\\s+extension\\s+\(componentName)Style\\s+where\\s+Self\\s+==\\s+Base\(componentName)Style"
    let extensionRegex = try! NSRegularExpression(pattern: extensionPattern, options: [])
    
    guard let extensionMatch = extensionRegex.firstMatch(in: content, options: [], range: NSRange(content.startIndex..., in: content)),
          let extensionRange = Range(extensionMatch.range, in: content) else {
        return []
    }
    
    // Encontrar o bloco de código da extensão
    let extensionStart = content.distance(from: content.startIndex, to: extensionRange.upperBound)
    guard let openBraceIndex = content[extensionRange.upperBound...].firstIndex(of: "{") else {
        return []
    }
    
    var braceCount = 1
    var closeIndex = content.index(after: openBraceIndex)
    
    while braceCount > 0 && closeIndex < content.endIndex {
        let char = content[closeIndex]
        if char == "{" {
            braceCount += 1
        } else if char == "}" {
            braceCount -= 1
        }
        if braceCount > 0 {
            closeIndex = content.index(after: closeIndex)
        }
    }
    
    if braceCount == 0 {
        let extensionContent = String(content[openBraceIndex...closeIndex])
        
        // Extrair funções de estilo
        let functionPattern = "static\\s+func\\s+(\\w+)\\s*\\(\\s*(?:_\\s+)?(\\w+)\\s*:\\s*(\\w+)(?:\\s*(?:,|\\)|\\s))?"
        let functionRegex = try! NSRegularExpression(pattern: functionPattern, options: [])
        let functionMatches = functionRegex.matches(in: extensionContent, options: [], range: NSRange(extensionContent.startIndex..., in: extensionContent))
        
        for match in functionMatches {
            guard let nameRange = Range(match.range(at: 1), in: extensionContent),
                  let paramNameRange = Range(match.range(at: 2), in: extensionContent),
                  let paramTypeRange = Range(match.range(at: 3), in: extensionContent) else {
                continue
            }
            
            let funcName = String(extensionContent[nameRange])
            let paramName = String(extensionContent[paramNameRange])
            let paramType = String(extensionContent[paramTypeRange])
            
            styleFunctions.append(StyleFunction(
                name: funcName,
                paramName: paramName,
                paramType: paramType
            ))
        }
    }
    
    return styleFunctions
}

func extractStyleCases(from content: String) -> [String] {
    var cases: [String] = []
    
    // Procura por enum com nome StyleCase
    let enumPattern = "enum\\s+(\\w+StyleCase)"
    let enumRegex = try! NSRegularExpression(pattern: enumPattern, options: [])
    
    guard let enumMatch = enumRegex.firstMatch(in: content, options: [], range: NSRange(content.startIndex..., in: content)),
          let enumRange = Range(enumMatch.range(at: 1), in: content) else {
        return []
    }
    
    let enumName = String(content[enumRange])
    
    // Encontrar o bloco do enum
    let enumBlockPattern = "\(enumName)[^{]*\\{([^}]*)\\}"
    let enumBlockRegex = try! NSRegularExpression(pattern: enumBlockPattern, options: [.dotMatchesLineSeparators])
    
    guard let blockMatch = enumBlockRegex.firstMatch(in: content, options: [], range: NSRange(content.startIndex..., in: content)),
          let blockRange = Range(blockMatch.range(at: 1), in: content) else {
        return []
    }
    
    let casesContent = String(content[blockRange])
    
    // Extrair casos
    let casePattern = "case\\s+(\\w+)"
    let caseRegex = try! NSRegularExpression(pattern: casePattern, options: [])
    let caseMatches = caseRegex.matches(in: casesContent, options: [], range: NSRange(casesContent.startIndex..., in: casesContent))
    
    for match in caseMatches {
        guard let caseRange = Range(match.range(at: 1), in: casesContent) else {
            continue
        }
        
        let caseName = String(casesContent[caseRange])
        cases.append(caseName)
    }
    
    return cases
}

func categorizeProperties(_ properties: [SwiftProperty]) -> (
    enumProps: [SwiftProperty],
    textProps: [SwiftProperty],
    boolProps: [SwiftProperty],
    numberProps: [SwiftProperty]
) {
    var enumProps: [SwiftProperty] = []
    var textProps: [SwiftProperty] = []
    var boolProps: [SwiftProperty] = []
    var numberProps: [SwiftProperty] = []
    
    for prop in properties {
        // Ignorar propriedades específicas
        if ["body", "colors", "fonts"].contains(prop.name) {
            continue
        }
        
        // Detectar tipos de propriedades
        if prop.dataType.contains("Case") || ["FontName", "ColorName"].contains(prop.dataType) {
            enumProps.append(prop)
        } else if prop.dataType.contains("String") {
            textProps.append(prop)
        } else if prop.dataType.contains("Bool") {
            boolProps.append(prop)
        } else if ["Int", "Double", "CGFloat", "Float"].contains(where: { prop.dataType.contains($0) }) {
            numberProps.append(prop)
        }
    }
    
    return (enumProps, textProps, boolProps, numberProps)
}

func extractInitParams(from content: String, componentName: String) -> [InitParameter] {
    var initParams: [InitParameter] = []
    
    // Padrão para localizar inicializadores públicos
    let initPattern = "public\\s+init\\s*\\((.*?)\\)"
    let initRegex = try! NSRegularExpression(pattern: initPattern, options: [.dotMatchesLineSeparators])
    let initMatches = initRegex.matches(in: content, options: [], range: NSRange(content.startIndex..., in: content))
    
    for match in initMatches {
        guard let paramsRange = Range(match.range(at: 1), in: content) else {
            continue
        }
        
        let paramsStr = String(content[paramsRange]).trimmingCharacters(in: .whitespaces)
        if paramsStr.isEmpty {
            continue
        }
        
        // Dividir pelos parâmetros individuais (isso é complexo devido a possíveis closures aninhadas)
        // Implementação simplificada
        let params = splitParameters(paramsStr)
        
        for param in params {
            // Padrão para extrair detalhes do parâmetro
            let paramPattern = "(?:(\\w+)\\s+)?(\\w+)\\s*:\\s*([^=]+)(?:\\s*=\\s*(.+))?"
            let paramRegex = try! NSRegularExpression(pattern: paramPattern, options: [])
            
            guard let paramMatch = paramRegex.firstMatch(in: param, options: [], range: NSRange(param.startIndex..., in: param)) else {
                continue
            }
            
            var label: String? = nil
            if paramMatch.numberOfRanges > 1, let labelRange = Range(paramMatch.range(at: 1), in: param) {
                label = String(param[labelRange])
            }
            
            guard let nameRange = Range(paramMatch.range(at: 2), in: param),
                  let typeRange = Range(paramMatch.range(at: 3), in: param) else {
                continue
            }
            
            let name = String(param[nameRange])
            let type = String(param[typeRange]).trimmingCharacters(in: .whitespaces)
            
            var defaultValue: String? = nil
            if paramMatch.numberOfRanges > 4, let defaultValueRange = Range(paramMatch.range(at: 4), in: param) {
                defaultValue = String(param[defaultValueRange]).trimmingCharacters(in: .whitespaces)
            }
            
            // Determinar se é um parâmetro de closure/ação
            let isAction = type.contains("->")
            
            initParams.append(InitParameter(
                label: label,
                name: name,
                type: type,
                defaultValue: defaultValue,
                isAction: isAction
            ))
        }
    }
    
    return initParams
}

func splitParameters(_ paramsStr: String) -> [String] {
    var params: [String] = []
    var currentParam = ""
    var nestedLevel = 0
    
    for char in paramsStr {
        if char == "(" || char == "<" {
            nestedLevel += 1
            currentParam.append(char)
        } else if char == ")" || char == ">" {
            nestedLevel -= 1
            currentParam.append(char)
        } else if char == "," && nestedLevel == 0 {
            params.append(currentParam.trimmingCharacters(in: .whitespaces))
            currentParam = ""
        } else {
            currentParam.append(char)
        }
    }
    
    if !currentParam.isEmpty {
        params.append(currentParam.trimmingCharacters(in: .whitespaces))
    }
    
    return params
}

func detectButtonComponent(_ componentName: String, _ initParams: [InitParameter]) -> Bool {
    // Verifica se é um Button pelo nome
    if componentName == "Button" {
        return true
    }
    
    // Verifica se tem um parâmetro de ação típico de botões
    return initParams.contains { param in
        param.isAction && param.type.contains("Void")
    }
}

// MARK: - Funções para análise de componentes

func analyzeComponent(_ componentInfo: ComponentInfo) -> ComponentInfo {
    // Ler o conteúdo do arquivo View
    guard let viewContent = readFile(at: componentInfo.viewPath) else {
        return componentInfo
    }
    
    // Extrair parâmetros do inicializador
    componentInfo.publicInitParams = extractInitParams(from: viewContent, componentName: componentInfo.name)
    
    // Verificar se é um componente do tipo Button
    let isButton = detectButtonComponent(componentInfo.name, componentInfo.publicInitParams)
    
    // Para componentes do tipo Button, armazenar informações adicionais
    if isButton {
        log("Componente \(componentInfo.name) identificado como tipo Button")
        for param in componentInfo.publicInitParams where param.isAction {
            componentInfo.hasActionParam = true
            // Adicionar o parâmetro à lista de closure properties (convertendo para SwiftProperty)
            componentInfo.closureProperties.append(SwiftProperty(
                type: "var",
                name: param.name,
                dataType: param.type,
                defaultValue: param.defaultValue
            ))
            log("Parâmetro de ação encontrado: \(param.name)")
        }
    }
    
    // Categorizar propriedades complexas (que não são tipos simples)
    for prop in componentInfo.properties {
        if !["String", "Bool", "Int", "Double", "CGFloat", "Float"].contains(where: { prop.dataType.contains($0) }) && 
           !prop.dataType.contains("Case") && !["FontName", "ColorName"].contains(prop.dataType) {
            if prop.dataType.contains("->") {  // É uma closure
                componentInfo.closureProperties.append(prop)
            } else {
                componentInfo.complexProperties.append(prop)
            }
        }
    }
    
    return componentInfo
}

func findComponentFiles(_ componentName: String) -> ComponentInfo? {
    // Verificar primeiro se é um componente nativo
    if let nativeInfo = NATIVE_COMPONENTS[componentName] {
        log("Componente nativo encontrado: \(componentName)")
        let componentInfo = ComponentInfo(name: componentName, typePath: nativeInfo.typePath)
        componentInfo.isNative = true
        
        // Converter init params do formato nativo para o formato interno
        for param in nativeInfo.initParams {
            componentInfo.publicInitParams.append(InitParameter(
                label: param.label,
                name: param.name,
                type: param.type,
                defaultValue: param.defaultValue,
                isAction: param.isAction
            ))
        }
        
        componentInfo.exampleCode = nativeInfo.exampleCode
        
        // Verificar se o componente tem parâmetro de ação
        for param in componentInfo.publicInitParams where param.isAction {
            componentInfo.hasActionParam = true
            // Adicionar o parâmetro à lista de closure properties
            componentInfo.closureProperties.append(SwiftProperty(
                type: "var",
                name: param.name,
                dataType: param.type,
                defaultValue: param.defaultValue
            ))
            log("Parâmetro de ação encontrado: \(param.name)")
        }
        
        // Se for componente nativo, procurar apenas pelo arquivo de estilos
        let possiblePaths = [
            "\(COMPONENTS_PATH)/BaseElements/Natives/\(componentName)",
            "\(COMPONENTS_PATH)/BaseElements/Natives/\(componentName)"
        ]
        
        for path in possiblePaths {
            if FileManager.default.fileExists(atPath: path) {
                do {
                    let files = try FileManager.default.contentsOfDirectory(atPath: path)
                    for file in files {
                        if file.contains("\(componentName)Styles.swift") {
                            componentInfo.stylesPath = "\(path)/\(file)"
                            log("Arquivo de estilos encontrado: \(componentInfo.stylesPath)")
                            
                            // Extrair casos de estilo do arquivo de estilos
                            if let content = readFile(at: componentInfo.stylesPath) {
                                componentInfo.styleCases = extractStyleCases(from: content)
                                componentInfo.styleFunctions = extractStyleFunctions(from: content, componentName: componentName)
                                log("Casos de estilo encontrados: \(componentInfo.styleCases)")
                                log("Funções de estilo encontradas: \(componentInfo.styleFunctions.map { $0.name })")
                            }
                            break
                        }
                    }
                } catch {
                    log("Erro ao listar arquivos em \(path): \(error)", level: .error)
                }
            }
        }
        
        // Se não encontrou style cases ou funções, definir valores padrão
        if componentInfo.styleCases.isEmpty && componentInfo.styleFunctions.isEmpty {
            componentInfo.styleCases = [nativeInfo.defaultStyleCase]
            log("Usando caso de estilo padrão: \(componentInfo.styleCases)")
        }
        
        return componentInfo
    }
    
    // Para componentes não nativos, seguir o fluxo normal
    var componentInfo: ComponentInfo?
    
    // Determinar o tipo de componente (BaseElements/Natives ou Components/Customs)
    let possiblePaths = [
        "\(COMPONENTS_PATH)/BaseElements/Natives/\(componentName)",
        "\(COMPONENTS_PATH)/Components/Customs/\(componentName)",
        "\(COMPONENTS_PATH)/BaseElements/Natives/\(componentName)",
        "\(COMPONENTS_PATH)/Components/Customs/\(componentName)"
    ]
    
    // Verificar se algum dos caminhos possíveis existe
    var foundPath: String?
    for basePath in possiblePaths {
        if FileManager.default.fileExists(atPath: basePath) {
            log("Componente encontrado em: \(basePath)")
            foundPath = basePath
            let typePath = basePath.contains("BaseElements") ? "BaseElements/Natives" : "Components/Customs"
            componentInfo = ComponentInfo(name: componentName, typePath: typePath)
            break
        }
    }
    
    guard let componentInfo = componentInfo, let foundPath = foundPath else {
        log("Componente '\(componentName)' não encontrado. Caminhos verificados: \(possiblePaths)", level: .error)
        return nil
    }
    
    // Localizar arquivos View, Configuration e Styles
    do {
        let files = try FileManager.default.contentsOfDirectory(atPath: foundPath)
        log("Arquivos encontrados no diretório do componente: \(files)")
        
        for file in files {
            let filePath = "\(foundPath)/\(file)"
            log("Verificando arquivo: \(filePath)")
            
            if file.contains("\(componentName)View") {
                componentInfo.viewPath = filePath
                log("View encontrada: \(filePath)")
            } else if file.contains("\(componentName)Configuration") {
                componentInfo.configPath = filePath
                log("Configuration encontrada: \(filePath)")
            } else if file.contains("\(componentName)Styles") {
                componentInfo.stylesPath = filePath
                log("Styles encontrada: \(filePath)")
            }
        }
    } catch {
        log("Erro ao listar arquivos do componente: \(error)", level: .error)
        return componentInfo
    }
    
    // Verificar se encontrou os arquivos necessários
    if componentInfo.viewPath.isEmpty {
        log("View não encontrada para o componente \(componentName)", level: .warning)
    }
    
    // Extrair propriedades, funções de estilo e casos de estilo
    if !componentInfo.viewPath.isEmpty, let content = readFile(at: componentInfo.viewPath) {
        log("Analisando view: \(componentInfo.viewPath)")
        componentInfo.properties = extractProperties(from: content)
        
        // Categorizar propriedades
        let (enumProps, textProps, boolProps, numberProps) = categorizeProperties(componentInfo.properties)
        componentInfo.enumProperties = enumProps
        componentInfo.textProperties = textProps
        componentInfo.boolProperties = boolProps
        componentInfo.numberProperties = numberProps
        
        log("Propriedades extraídas: \(componentInfo.properties.map { $0.name })")
    }
    
    if !componentInfo.stylesPath.isEmpty, let content = readFile(at: componentInfo.stylesPath) {
        log("Analisando arquivo de estilos: \(componentInfo.stylesPath)")
        componentInfo.styleFunctions = extractStyleFunctions(from: content, componentName: componentName)
        
        // Se não encontrou funções de estilo, tenta extrair do StyleCase (para compatibilidade)
        if componentInfo.styleFunctions.isEmpty {
            log("Tentando extrair casos de estilo (StyleCase)")
            componentInfo.styleCases = extractStyleCases(from: content)
            log("Casos de estilo encontrados: \(componentInfo.styleCases)")
        }
    }
    
    // Se for o componente Button, definir valores padrão específicos
    if componentName == "Button" {
        log("Configurando valores específicos para Button")
        if componentInfo.styleCases.isEmpty {
            componentInfo.styleCases = ["contentA", "highlightA", "backgroundD"]
            log("Definindo casos de estilo padrão para Button: \(componentInfo.styleCases)")
        }
    }
    
    return componentInfo
}

// MARK: - Geração de arquivos

func generateNativeComponentSample(_ componentInfo: ComponentInfo) -> String {
    let componentName = componentInfo.name
    let sampleName = "\(componentName)Sample"
    
    // Importações básicas
    let imports = """
    import SwiftUI
    import Zenith
    import ZenithCoreInterface
    """
    
    // Determinar configurações específicas do componente
    let hasContentParam = ["Text", "Button", "Toggle", "TextField"].contains(componentName)
    let isButtonType = componentName == "Button" || componentInfo.hasActionParam
    let styleModifier = "\(componentName.lowercased())Style"
    let styleType = "\(componentName)Style"
    let styleCaseType = "\(componentName)StyleCase"
    
    // Início da estrutura
    let structStart = """
    
    struct \(sampleName): View, @preconcurrency BaseThemeDependencies {
        @Dependency(\\.themeConfigurator) var themeConfigurator
    """
    
    // Estados básicos
    var states: [String] = []
    
    // Estado para texto de exemplo se o componente precisar
    if hasContentParam {
        if componentName == "Text" {
            states.append("    @State private var sampleText = \"Exemplo de texto\"")
        } else if componentName == "Button" {
            states.append("    @State private var buttonTitle = \"Botão de Exemplo\"")
        } else if componentName == "Toggle" {
            states.append("    @State private var toggleLabel = \"Toggle de Exemplo\"")
            states.append("    @State private var isEnabled = false")
        } else if componentName == "TextField" {
            states.append("    @State private var textValue = \"\"")
            states.append("    @State private var placeholder = \"Digite aqui\"")
        }
    }
    
    // Estados para estilo
    if !componentInfo.styleCases.isEmpty {
        let defaultStyle = componentInfo.styleCases[0]
        states.append("    @State private var selectedStyle = \(styleCaseType).\(defaultStyle)")
    } else if !componentInfo.styleFunctions.isEmpty {
        let defaultStyle = componentInfo.styleFunctions[0]
        if defaultStyle.paramType == "ColorName" {
            states.append("    @State private var selectedColorName: ColorName = .contentA")
            states.append("    @State private var selectedStyleFunction = \"\(defaultStyle.name)\"")
        }
    }
    
    // Toggles para opções de visualização
    let viewOptions = """
        @State private var showAllStyles = false
        @State private var useContrastBackground = true
        @State private var showFixedHeader = false
    """
    
    // Implementação do body com preview e configuração
    let bodyContent = """
        
        var body: some View {
            SampleWithFixedHeader(
                showFixedHeader: $showFixedHeader,
                content: {
                    Card(action: {
                        showFixedHeader.toggle()
                    }) {
                        VStack(spacing: 16) {
                            // Preview do componente com configurações atuais
                            previewComponent
                        }
                        .padding()
                    }
                    .padding()
                },
                config: {
                    VStack(spacing: 16) {
                        // Área de configuração
                        configurationSection
                        
                        // Preview do código gerado
                        CodePreviewSection(generateCode: generateSwiftCode)
                        
                        // Exibição de todos os estilos (opcional)
                        if showAllStyles {
                            Divider().padding(.vertical, 4)
                            
                            VStack(alignment: .leading, spacing: 12) {
                                Text("Todos os Estilos")
                                    .font(fonts.mediumBold)
                                    .foregroundColor(colors.contentA)
                                
                                scrollViewWithStyles
                            }
                        }
                    }
                    .padding(.horizontal)
                }
            )
        }
    """
    
    // ScrollView com todos os estilos
    var exampleType = styleCaseType
    var exampleCode = "// Exemplo do componente"
    
    switch componentName {
    case "Button":
        exampleCode = "Button(buttonTitle) {\n                                // Ação vazia para exemplo\n                            }\n                            .buttonStyle(style.style())"
    case "Text":
        exampleCode = "Text(sampleText)\n                            .textStyle(style.style())"
    case "Divider":
        exampleCode = "Divider()\n                            .dividerStyle(style.style())"
    case "Toggle":
        exampleCode = "Toggle(toggleLabel, isOn: .constant(true))\n                            .toggleStyle(style.style())"
    case "TextField":
        exampleCode = "TextField(placeholder, text: .constant(\"Exemplo\"))\n                            .textFieldStyle(style.style())"
    default:
        break
    }
    
    let scrollView = """
        
        private var scrollViewWithStyles: some View {
            ScrollView {
                VStack(alignment: .leading, spacing: 8) {
                    LazyVGrid(columns: [GridItem(.adaptive(minimum: 160))], spacing: 8) {
                        ForEach(\(exampleType).allCases, id: \\.self) { style in
                            VStack {
                                Text(String(describing: style))
                                    .font(fonts.small)
                                    .foregroundColor(colors.contentA)
                                    .padding(.bottom, 2)
                                
                                \(exampleCode)
                                    .padding(8)
                                    .frame(maxWidth: .infinity)
                                    .background(
                                        RoundedRectangle(cornerRadius: 4)
                                            .fill(getContrastBackground(for: getColorFromStyle(style)))
                                    )
                            }
                        }
                    }
                }
            }
            .frame(maxHeight: 200)
        }
    """
    
    // Criando a seção de preview do componente
    var previewComponent = """
        
        // Preview do componente com as configurações selecionadas
        private var previewComponent: some View {
            VStack {
                // Preview do componente com as configurações atuais
    """
    
    // Adicionar o exemplo correto para cada tipo de componente
    switch componentName {
    case "Button":
        previewComponent += """
                    Button(buttonTitle) {
                        print("Botão pressionado")
                    }
                    .buttonStyle(selectedStyle.style())
    """
    case "Text":
        previewComponent += """
                    Text(sampleText)
                        .textStyle(selectedStyle.style())
    """
    case "Divider":
        previewComponent += """
                    Divider()
                        .dividerStyle(selectedStyle.style())
    """
    case "Toggle":
        previewComponent += """
                    Toggle(toggleLabel, isOn: $isEnabled)
                        .toggleStyle(selectedStyle.style())
    """
    case "TextField":
        previewComponent += """
                    TextField(placeholder, text: $textValue)
                        .textFieldStyle(selectedStyle.style())
    """
    default:
        previewComponent += "                // Preview de \(componentName)"
    }
    
    previewComponent += """
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(
                        RoundedRectangle(cornerRadius: 8)
                            .fill(useContrastBackground ? colors.backgroundA : colors.backgroundB.opacity(0.2))
                    )
                }
            }
    """
    
    // Configuração específica para cada componente
    var configurationSection = """
        
        // Área de configuração
        private var configurationSection: some View {
            VStack(spacing: 16) {
    """
    
    switch componentName {
    case "Button":
        configurationSection += """
                // Campo para texto do botão
                TextField("Texto do botão", text: $buttonTitle)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding(.horizontal)
    """
    case "Text":
        configurationSection += """
                // Campo para texto de exemplo
                TextField("Texto de exemplo", text: $sampleText)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding(.horizontal)
    """
    case "Toggle":
        configurationSection += """
                // Campo para label do toggle
                TextField("Label do toggle", text: $toggleLabel)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding(.horizontal)
                    
                // Toggle para testar o componente
                Toggle("Estado do toggle", isOn: $isEnabled)
                    .toggleStyle(.default(.contentA))
                    .padding(.horizontal)
    """
    case "TextField":
        configurationSection += """
                // Campo para valor do texto
                TextField("Valor do texto", text: $textValue)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding(.horizontal)
                    
                // Campo para placeholder
                TextField("Placeholder", text: $placeholder)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding(.horizontal)
    """
    default:
        break
    }
    
    // Adicionar seletor de estilo para todos os componentes
    configurationSection += """
                
                // Seletor de estilo
                EnumSelector<\(styleCaseType)>(
                    title: "Estilo",
                    selection: $selectedStyle,
                    columnsCount: 3,
                    height: 120
                )
                
                // Toggles para opções
                VStack {
                    Toggle("Usar fundo contrastante", isOn: $useContrastBackground)
                        .toggleStyle(.default(.highlightA))
                    
                    Toggle("Mostrar Todos os Estilos", isOn: $showAllStyles)
                        .toggleStyle(.default(.highlightA))
                }
                .padding(.horizontal)
            }
        }
    """
    
    // Geração de código Swift
    var generateCode = """
        
        // Gera o código Swift para o componente configurado
        private func generateSwiftCode() -> String {
            // Aqui você pode personalizar a geração de código com base no componente
            var code = "// Código gerado automaticamente\\n"
            
            code +=
    """
    
    // Código específico para cada componente
    switch componentName {
    case "Button":
        generateCode += """
    Button("\\(buttonTitle)") {
        // Ação do botão aqui
    }
    .buttonStyle(selectedStyle.style())
    """
    case "Text":
        generateCode += """
    Text("\\(sampleText)")
        .textStyle(selectedStyle.style())
    """
    case "Divider":
        generateCode += """
    Divider()
        .dividerStyle(selectedStyle.style())
    """
    case "Toggle":
        generateCode += """
    Toggle("\\(toggleLabel)", isOn: $isEnabled)
        .toggleStyle(selectedStyle.style())
    """
    case "TextField":
        generateCode += """
    TextField("\\(placeholder)", text: $textValue)
        .textFieldStyle(selectedStyle.style())
    """
    default:
        break
    }
    
    generateCode += """
            """
    
    generateCode += """
            
            return code
        }
    """
    
    // Helper methods padrão
    let helperMethods = """
        
        // Helper para obter a cor associada a um StyleCase
        private func getColorFromStyle<T>(_ style: T) -> ColorName {
            let styleName = String(describing: style)
            
            if styleName.contains("HighlightA") {
                return .highlightA
            } else if styleName.contains("BackgroundA") {
                return .backgroundA
            } else if styleName.contains("BackgroundB") {
                return .backgroundB
            } else if styleName.contains("BackgroundC") {
                return .backgroundC
            } else if styleName.contains("BackgroundD") {
                return .backgroundD
            } else if styleName.contains("ContentA") {
                return .contentA
            } else if styleName.contains("ContentB") {
                return .contentB
            } else if styleName.contains("ContentC") {
                return .contentC
            } else if styleName.contains("Critical") {
                return .critical
            } else if styleName.contains("Attention") {
                return .attention
            } else if styleName.contains("Danger") {
                return .danger
            } else if styleName.contains("Positive") {
                return .positive
            } else {
                return .none
            }
        }
        
        // Gera um fundo de contraste adequado para a cor especificada
        private func getContrastBackground(for colorName: ColorName) -> Color {
            let color = colors.color(by: colorName) ?? colors.backgroundB
            
            // Extrair componentes RGB da cor
            let uiColor = UIColor(color)
            var red: CGFloat = 0
            var green: CGFloat = 0
            var blue: CGFloat = 0
            var alpha: CGFloat = 0
            
            uiColor.getRed(&red, green: &green, blue: &blue, alpha: &alpha)
            
            // Calcular luminosidade da cor (fórmula perceptual)
            let luminance = 0.299 * red + 0.587 * green + 0.114 * blue
            
            // Verificar se estamos lidando com a cor backgroundC ou cores com luminosidade similar
            if (abs(luminance - 0.27) < 0.1) { // 0.27 é aproximadamente a luminosidade de #444444
                // Para cinzas médios como backgroundC, criar um contraste mais definido
                if luminance < 0.3 {
                    // Para cinzas que tendem ao escuro, usar um contraste bem claro
                    return Color.white.opacity(0.25)
                } else {
                    // Para cinzas que tendem ao claro, usar um contraste bem escuro
                    return Color.black.opacity(0.15)
                }
            }
            
            // Para as demais cores, manter a lógica anterior mas aumentar o contraste
            if luminance < 0.5 {
                // Para cores escuras, gerar um contraste claro
                return Color(red: min(red + 0.4, 1.0), 
                            green: min(green + 0.4, 1.0), 
                            blue: min(blue + 0.4, 1.0))
                    .opacity(0.35)
            } else {
                // Para cores claras, gerar um contraste escuro
                return Color(red: max(red - 0.25, 0.0), 
                            green: max(green - 0.25, 0.0), 
                            blue: max(blue - 0.25, 0.0))
                    .opacity(0.2)
            }
        }
    """
    
    // Combinar tudo
    var fullContent = imports
    fullContent += structStart
    fullContent += states.joined(separator: "\n")
    fullContent += "\n" + viewOptions
    fullContent += bodyContent
    fullContent += scrollView
    fullContent += previewComponent
    fullContent += configurationSection
    fullContent += generateCode
    fullContent += helperMethods
    fullContent += "\n}"  // Fechar a struct
    
    return fullContent
}

func createSampleFile(for componentName: String) -> Bool {
    log("Criando amostra para o componente: \(componentName)")
    
    // Procurar informações do componente
    guard let componentInfo = findComponentFiles(componentName) else {
        log("Não foi possível encontrar o componente: \(componentName)", level: .error)
        return false
    }
    
    // Determinar o caminho para salvar o arquivo Sample
    let samplePath = "\(SAMPLES_PATH)/\(componentInfo.typePath)/\(componentName)"
    
    // Criar os diretórios, se necessário
    do {
        try FileManager.default.createDirectory(atPath: samplePath, withIntermediateDirectories: true)
    } catch {
        log("Erro ao criar diretórios: \(error)", level: .error)
        return false
    }
    
    // Gerar o conteúdo do arquivo Sample
    var sampleContent: String
    
    if componentInfo.isNative {
        sampleContent = generateNativeComponentSample(componentInfo)
    } else {
        // Esta parte implementaria o método generateSampleFile, que é mais complexo
        // Para simplificar, podemos usar o mesmo método para componentes nativos por enquanto
        sampleContent = generateNativeComponentSample(componentInfo)
    }
    
    // Salvar o arquivo
    let sampleFilePath = "\(samplePath)/\(componentName)Sample.swift"
    do {
        try sampleContent.write(toFile: sampleFilePath, atomically: true, encoding: .utf8)
        log("Arquivo Sample criado com sucesso: \(sampleFilePath)")
        return true
    } catch {
        log("Erro ao criar o arquivo Sample: \(error)", level: .error)
        return false
    }
}

// MARK: - Menu Principal e Interface de Usuário

func mainMenu() {
    clearConsole()
    ConsoleUI.printTitle("KettleGym - Gerador de Componentes Zenith")
    
    let options = [
        "Gerar Sample para um componente específico",
        "Listar componentes disponíveis",
        "Gerar Samples para todos os componentes nativos",
        "Gerar Sample para componente personalizado",
        "Sair"
    ]
    
    let choice = ConsoleUI.promptForChoice("Escolha uma opção:", options: options)
    
    switch choice {
    case 1:
        componentSelectionMenu()
    case 2:
        listAvailableComponents()
    case 3:
        generateAllNativeComponentSamples()
    case 4:
        createCustomComponentSample()
    case 5:
        print("Saindo do programa.")
        exit(0)
    default:
        ConsoleUI.printError("Opção inválida.")
        mainMenu()
    }
}

func componentSelectionMenu() {
    clearConsole()
    ConsoleUI.printTitle("Selecionar Componente")
    
    let components = findAvailableComponents()
    let paginationSize = 10
    var page = 0
    let totalPages = (components.count - 1) / paginationSize + 1
    
    while true {
        clearConsole()
        ConsoleUI.printTitle("Selecionar Componente (Página \(page + 1) de \(totalPages))")
        
        let startIndex = page * paginationSize
        let endIndex = min(startIndex + paginationSize, components.count)
        
        for i in startIndex..<endIndex {
            ConsoleUI.printOption(i - startIndex + 1, components[i])
        }
        
        print("\n\(ConsoleUI.yellow)[N]\(ConsoleUI.reset) Próxima página")
        print("\(ConsoleUI.yellow)[P]\(ConsoleUI.reset) Página anterior")
        print("\(ConsoleUI.yellow)[V]\(ConsoleUI.reset) Voltar ao menu principal")
        
        let input = ConsoleUI.promptForInput("Escolha um componente ou uma opção")
        
        if input.lowercased() == "n" {
            page = (page + 1) % totalPages
        } else if input.lowercased() == "p" {
            page = (page - 1 + totalPages) % totalPages
        } else if input.lowercased() == "v" {
            mainMenu()
            return
        } else if let choice = Int(input), choice >= 1, choice <= endIndex - startIndex {
            let selectedComponent = components[startIndex + choice - 1]
            processComponent(selectedComponent)
            return
        } else {
            ConsoleUI.printError("Opção inválida.")
            pauseForAction()
        }
    }
}

func listAvailableComponents() {
    clearConsole()
    ConsoleUI.printTitle("Componentes Disponíveis")
    
    let components = findAvailableComponents()
    
    if components.isEmpty {
        ConsoleUI.printInfo("Nenhum componente encontrado.")
    } else {
        // Criar colunas para melhor visualização
        let columnsCount = 3
        let rows = (components.count + columnsCount - 1) / columnsCount
        
        for row in 0..<rows {
            var rowOutput = ""
            for col in 0..<columnsCount {
                let index = row + col * rows
                if index < components.count {
                    let component = components[index]
                    // Padronizar tamanho para alinhamento em colunas
                    let paddedComponent = component.padding(toLength: 25, withPad: " ", startingAt: 0)
                    rowOutput += paddedComponent
                }
            }
            print(rowOutput)
        }
    }
    
    pauseForAction()
    mainMenu()
}

func generateAllNativeComponentSamples() {
    clearConsole()
    ConsoleUI.printTitle("Gerando Samples para Componentes Nativos")
    
    let nativeComponents = Array(NATIVE_COMPONENTS.keys).sorted()
    var success = 0
    var failure = 0
    
    for component in nativeComponents {
        ConsoleUI.printInfo("Processando: \(component)")
        let result = createSampleFile(for: component)
        if result {
            ConsoleUI.printSuccess("Sample gerado com sucesso para: \(component)")
            success += 1
        } else {
            ConsoleUI.printError("Falha ao gerar sample para: \(component)")
            failure += 1
        }
    }
    
    print("\nResumo:")
    ConsoleUI.printSuccess("Total de samples gerados com sucesso: \(success)")
    if failure > 0 {
        ConsoleUI.printError("Total de falhas: \(failure)")
    }
    
    pauseForAction()
    mainMenu()
}

func createCustomComponentSample() {
    clearConsole()
    ConsoleUI.printTitle("Criar Sample para Componente Personalizado")
    
    let componentName = ConsoleUI.promptForInput("Digite o nome do componente personalizado")
    
    if componentName.isEmpty {
        ConsoleUI.printError("Nome do componente não pode ser vazio.")
        pauseForAction()
        mainMenu()
        return
    }
    
    ConsoleUI.printInfo("Tentando criar sample para: \(componentName)")
    let result = createSampleFile(for: componentName)
    
    if result {
        ConsoleUI.printSuccess("Sample criado com sucesso para: \(componentName)")
    } else {
        ConsoleUI.printError("Falha ao criar sample para: \(componentName)")
    }
    
    pauseForAction()
    mainMenu()
}

func processComponent(_ componentName: String) {
    clearConsole()
    ConsoleUI.printTitle("Processando Componente: \(componentName)")
    
    ConsoleUI.printInfo("Analisando componente...")
    let result = createSampleFile(for: componentName)
    
    if result {
        ConsoleUI.printSuccess("Sample criado com sucesso para: \(componentName)")
    } else {
        ConsoleUI.printError("Falha ao criar sample para: \(componentName)")
    }
    
    pauseForAction()
    mainMenu()
}

// MARK: - Main

// Se executado com argumentos, usar modo de linha de comando
// Senão, iniciar interface interativa
if CommandLine.arguments.count > 1 {
    let componentName = CommandLine.arguments[1]
    let success = createSampleFile(for: componentName)
    exit(success ? 0 : 1)
} else {
    // Iniciar interface interativa
    mainMenu()
}
