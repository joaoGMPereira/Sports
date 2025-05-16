import Foundation

// MARK: - Modelos de dados

struct SwiftProperty {
    let type: String // var ou let
    let name: String
    let dataType: String
    let defaultValue: String?
}

struct StyleParameter {
    let name: String
    let type: String
    let defaultValue: String?
}

struct StyleFunction {
    let name: String
    let parameters: [StyleParameter]
    
    // Para manter compatibilidade com o código existente
    var paramName: String {
        parameters.first?.name ?? "color"
    }
    
    var paramType: String {
        parameters.first?.type ?? "ColorName"
    }
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

final class ComponentConfiguration {
    
    // Adicionar funções que estão faltando
    func readFile(at path: String) -> String? {
        do {
            return try String(contentsOfFile: path, encoding: .utf8)
        } catch {
            Log.log("Erro ao ler o arquivo \(path): \(error)", level: .error)
            return nil
        }
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
        var uniqueFunctionNames = Set<String>() // Para evitar duplicações
        
        // Log para debug
        Log.log("Extraindo funções de estilo para \(componentName)", level: .info)
        
        // Padrão simplificado para localizar extensões de estilo do componente
        // Captura qualquer extensão pública que se refira ao estilo do componente
        let extensionPatterns = [
            // Extensões específicas para o componente
            "public\\s+extension\\s+\(componentName)Style"
        ]
        
        // Encontra todas as extensões no conteúdo
        var extensionRanges: [(ClosedRange<String.Index>, String)] = []
        
        for pattern in extensionPatterns {
            let regex = try! NSRegularExpression(pattern: pattern, options: [])
            let matches = regex.matches(in: content, options: [], range: NSRange(content.startIndex..., in: content))
            
            for match in matches {
                guard let extensionRange = Range(match.range, in: content) else { continue }
                let extensionType = String(content[extensionRange])
                
                // Encontrar o bloco de código da extensão
                guard let openBraceIndex = content[extensionRange.upperBound...].firstIndex(of: "{") else { continue }
                
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
                    let blockRange = content[openBraceIndex...closeIndex]
                    extensionRanges.append((openBraceIndex...closeIndex, String(blockRange)))
                }
            }
        }
        
        // Extrai as funções de cada bloco de extensão
        for (_, extensionContent) in extensionRanges {
            let functions = extractFunctionsFromBlock(extensionContent)
            for function in functions {
                if !uniqueFunctionNames.contains(function.name) {
                    uniqueFunctionNames.insert(function.name)
                    styleFunctions.append(function)
                }
            }
        }
        
        // Além disso, procurar diretamente por static func que retornam Self
        // Isso captura funções que possam estar em outras extensões
        let directFunctions = extractAllStaticFunctionsFromContent(content)
        
        // Adicionar funções encontradas diretamente, se ainda não foram adicionadas
        for function in directFunctions {
            if !uniqueFunctionNames.contains(function.name) {
                uniqueFunctionNames.insert(function.name)
                styleFunctions.append(function)
                Log.log("Função de estilo encontrada diretamente: \(function.name)", level: .info)
            }
        }
        
        // Log para debug
        Log.log("Funções de estilo encontradas: \(styleFunctions.map { $0.name }.joined(separator: ", "))", level: .info)
        
        return styleFunctions.isEmpty ? extractGenericStyleFunctions(from: content, componentName: componentName) : styleFunctions
    }
    
    // Função melhorada para extrair todas as funções static -> Self do conteúdo
    func extractAllStaticFunctionsFromContent(_ content: String) -> [StyleFunction] {
        var styleFunctions: [StyleFunction] = []
        var uniqueFunctionNames = Set<String>()
        
        // Padrão universal para funções estáticas que retornam Self
        // Captura qualquer função estática independente de qual extensão ela está
        // Usamos um padrão mais robusto que consegue lidar com parênteses aninhados nos valores padrão
        let staticFuncPattern = "static\\s+func\\s+(\\w+)\\s*\\((.*?)\\)\\s*->\\s*Self"
        let funcRegex = try! NSRegularExpression(pattern: staticFuncPattern, options: [.dotMatchesLineSeparators])
        let funcMatches = funcRegex.matches(in: content, options: [], range: NSRange(content.startIndex..., in: content))
        
        for match in funcMatches {
            guard let nameRange = Range(match.range(at: 1), in: content) else { continue }
            let funcName = String(content[nameRange])
            
            if !uniqueFunctionNames.contains(funcName) {
                uniqueFunctionNames.insert(funcName)
                
                // Extrair parâmetros
                var parameters: [StyleParameter] = []
                if match.numberOfRanges > 2, let paramsRange = Range(match.range(at: 2), in: content) {
                    let paramsString = String(content[paramsRange]).trimmingCharacters(in: .whitespaces)
                    
                    if !paramsString.isEmpty {
                        let paramsList = splitFunctionParameters(paramsString)
                        
                        for param in paramsList {
                            if let styleParam = parseParameter(param) {
                                parameters.append(styleParam)
                            }
                        }
                    }
                }
                
                // Se não houver parâmetros, adicionar um padrão
                if parameters.isEmpty {
                    parameters = [StyleParameter(name: "color", type: "ColorName", defaultValue: nil)]
                }
                
                styleFunctions.append(StyleFunction(name: funcName, parameters: parameters))
            }
        }
        
        return styleFunctions
    }
    
    func extractFunctionsFromBlock(_ content: String) -> [StyleFunction] {
        var functions: [StyleFunction] = []
        
        // Padrão para encontrar funções estáticas que retornam Self
        // Usamos um padrão mais robusto que consegue lidar com parênteses aninhados nos valores padrão
        let functionPattern = "static\\s+func\\s+(\\w+)\\s*\\((.*?)\\)\\s*->\\s*Self"
        let functionRegex = try! NSRegularExpression(pattern: functionPattern, options: [.dotMatchesLineSeparators])
        let functionMatches = functionRegex.matches(in: content, options: [], range: NSRange(content.startIndex..., in: content))
        
        for match in functionMatches {
            guard let nameRange = Range(match.range(at: 1), in: content) else { continue }
            let funcName = String(content[nameRange])
            
            var parameters: [StyleParameter] = []
            
            // Extrair os parâmetros
            if match.numberOfRanges > 2, let paramsRange = Range(match.range(at: 2), in: content) {
                let paramsString = String(content[paramsRange]).trimmingCharacters(in: .whitespaces)
                
                if !paramsString.isEmpty {
                    let paramsList = splitFunctionParameters(paramsString)
                    
                    for param in paramsList {
                        if let styleParam = parseParameter(param) {
                            parameters.append(styleParam)
                        }
                    }
                }
            }
            
            // Se não houver parâmetros, adicione um padrão para compatibilidade
            if parameters.isEmpty {
                parameters = [StyleParameter(name: "color", type: "ColorName", defaultValue: nil)]
            }
            
            functions.append(StyleFunction(name: funcName, parameters: parameters))
        }
        
        return functions
    }
    
    func parseParameter(_ paramString: String) -> StyleParameter? {
        // Padrão para extrair nome e tipo do parâmetro + valor padrão opcional
        let paramPattern = "(?:_\\s+)?(\\w+)\\s*:\\s*([^=]+)(?:\\s*=\\s*(.+))?"
        let paramRegex = try! NSRegularExpression(pattern: paramPattern, options: [])
        
        guard let match = paramRegex.firstMatch(in: paramString, options: [], range: NSRange(paramString.startIndex..., in: paramString)) else {
            return nil
        }
        
        guard let nameRange = Range(match.range(at: 1), in: paramString),
              let typeRange = Range(match.range(at: 2), in: paramString) else {
            return nil
        }
        
        let name = String(paramString[nameRange])
        let type = String(paramString[typeRange]).trimmingCharacters(in: .whitespaces)
        
        var defaultValue: String? = nil
        if match.numberOfRanges > 3, let defaultValueRange = Range(match.range(at: 3), in: paramString) {
            defaultValue = String(paramString[defaultValueRange]).trimmingCharacters(in: .whitespaces)
        }
        
        return StyleParameter(name: name, type: type, defaultValue: defaultValue)
    }
    
    func splitFunctionParameters(_ paramsString: String) -> [String] {
        var params: [String] = []
        var currentParam = ""
        var braceCount = 0
        var inQuotes = false
        
        for char in paramsString {
            switch char {
            case "," where braceCount == 0 && !inQuotes:
                params.append(currentParam.trimmingCharacters(in: .whitespaces))
                currentParam = ""
            case "(", "[", "{":
                braceCount += 1
                currentParam.append(char)
            case ")", "]", "}":
                braceCount -= 1
                currentParam.append(char)
            case "\"":
                inQuotes.toggle()
                currentParam.append(char)
            default:
                currentParam.append(char)
            }
        }
        
        if !currentParam.trimmingCharacters(in: .whitespaces).isEmpty {
            params.append(currentParam.trimmingCharacters(in: .whitespaces))
        }
        
        return params
    }

    func extractGenericStyleFunctions(from content: String, componentName: String) -> [StyleFunction] {
        var styleFunctions: [StyleFunction] = []
        
        // Procura por padrões como: static func contentA() -> Self { .init() }
        // ou static func small(_ color: ColorName) -> Self { ... }
        // Usamos um padrão mais robusto que consegue lidar com parênteses aninhados nos valores padrão
        let genericFunctionPattern = "static\\s+func\\s+(\\w+)\\s*\\((.*?)\\)\\s*->\\s*Self"
        let functionRegex = try! NSRegularExpression(pattern: genericFunctionPattern, options: [.dotMatchesLineSeparators])
        let functionMatches = functionRegex.matches(in: content, options: [], range: NSRange(content.startIndex..., in: content))
        
        for match in functionMatches {
            guard let nameRange = Range(match.range(at: 1), in: content) else { continue }
            let funcName = String(content[nameRange])
            
            var parameters: [StyleParameter] = []
            
            // Extrair os parâmetros
            if match.numberOfRanges > 2, let paramsRange = Range(match.range(at: 2), in: content) {
                let paramsString = String(content[paramsRange]).trimmingCharacters(in: .whitespaces)
                
                if !paramsString.isEmpty {
                    let paramsList = splitFunctionParameters(paramsString)
                    
                    for param in paramsList {
                        if let styleParam = parseParameter(param) {
                            parameters.append(styleParam)
                        }
                    }
                }
            }
            
            // Se não houver parâmetros, adicione um padrão para compatibilidade
            if parameters.isEmpty {
                parameters = [StyleParameter(name: "color", type: "ColorName", defaultValue: nil)]
            }
            
            styleFunctions.append(StyleFunction(name: funcName, parameters: parameters))
        }
        
        // Se ainda não encontrou funções, procura por casos do enum StyleCase
        if styleFunctions.isEmpty {
            styleFunctions = inferStyleFunctionsFromEnum(in: content, componentName: componentName)
        }
        
        // Se ainda não encontrou nada, adiciona um padrão mínimo
        if styleFunctions.isEmpty {
            Log.log("Não foi possível encontrar funções de estilo para \(componentName), usando padrão mínimo", level: .warning)
            let defaultFunctions: [StyleFunction]
            
            // Define funções padrão específicas por componente
            switch componentName {
            case "Text":
                defaultFunctions = [
                    StyleFunction(name: "small", parameters: [StyleParameter(name: "color", type: "ColorName", defaultValue: nil)]),
                    StyleFunction(name: "medium", parameters: [StyleParameter(name: "color", type: "ColorName", defaultValue: nil)]),
                    StyleFunction(name: "large", parameters: [StyleParameter(name: "color", type: "ColorName", defaultValue: nil)])
                ]
            case "Button":
                defaultFunctions = [
                    StyleFunction(name: "contentA", parameters: [
                        StyleParameter(name: "shape", type: "ButtonShape", defaultValue: ".rounded(cornerRadius: .infinity)"),
                        StyleParameter(name: "state", type: "DSState", defaultValue: ".enabled")
                    ]),
                    StyleFunction(name: "highlightA", parameters: [
                        StyleParameter(name: "shape", type: "ButtonShape", defaultValue: ".rounded(cornerRadius: .infinity)"),
                        StyleParameter(name: "state", type: "DSState", defaultValue: ".enabled")
                    ]),
                    StyleFunction(name: "backgroundD", parameters: [
                        StyleParameter(name: "shape", type: "ButtonShape", defaultValue: ".rounded(cornerRadius: .infinity)"),
                        StyleParameter(name: "state", type: "DSState", defaultValue: ".enabled")
                    ])
                ]
            case "Toggle":
                defaultFunctions = [
                    StyleFunction(name: "default", parameters: [StyleParameter(name: "color", type: "ColorName", defaultValue: nil)])
                ]
            default:
                defaultFunctions = [
                    StyleFunction(name: "contentA", parameters: [StyleParameter(name: "color", type: "ColorName", defaultValue: nil)]),
                    StyleFunction(name: "contentB", parameters: [StyleParameter(name: "color", type: "ColorName", defaultValue: nil)]),
                    StyleFunction(name: "highlightA", parameters: [StyleParameter(name: "color", type: "ColorName", defaultValue: nil)])
                ]
            }
            
            styleFunctions = defaultFunctions
        }
        
        return styleFunctions
    }
    
    func inferStyleFunctionsFromEnum(in content: String, componentName: String) -> [StyleFunction] {
        var styleFunctions: [StyleFunction] = []
        
        // Procura por enum de casos de estilo
        let enumPattern = "enum\\s+\(componentName)StyleCase\\s*:.*?\\{([^}]*?)\\}"
        let enumRegex = try! NSRegularExpression(pattern: enumPattern, options: [.dotMatchesLineSeparators])
        
        guard let enumMatch = enumRegex.firstMatch(in: content, options: [], range: NSRange(content.startIndex..., in: content)),
              let enumContentRange = Range(enumMatch.range(at: 1), in: content) else {
            return []
        }
        
        let enumContent = String(content[enumContentRange])
        
        // Extrair casos
        let casePattern = "case\\s+(\\w+)"
        let caseRegex = try! NSRegularExpression(pattern: casePattern, options: [])
        let caseMatches = caseRegex.matches(in: enumContent, options: [], range: NSRange(enumContent.startIndex..., in: enumContent))
        
        for match in caseMatches {
            guard let caseNameRange = Range(match.range(at: 1), in: enumContent) else {
                continue
            }
            
            let caseName = String(enumContent[caseNameRange])
            
            // Se for Button, inferir parâmetros típicos
            if componentName == "Button" {
                styleFunctions.append(StyleFunction(
                    name: caseName,
                    parameters: [
                        StyleParameter(name: "shape", type: "ButtonShape", defaultValue: ".rounded(cornerRadius: .infinity)"),
                        StyleParameter(name: "state", type: "DSState", defaultValue: ".enabled")
                    ]
                ))
            } else {
                // Para outros componentes, usar valor padrão genérico
                styleFunctions.append(StyleFunction(
                    name: caseName,
                    parameters: [StyleParameter(name: "color", type: "ColorName", defaultValue: nil)]
                ))
            }
        }
        
        return styleFunctions
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
            Log.log("Componente \(componentInfo.name) identificado como tipo Button")
            for param in componentInfo.publicInitParams where param.isAction {
                componentInfo.hasActionParam = true
                // Adicionar o parâmetro à lista de closure properties (convertendo para SwiftProperty)
                componentInfo.closureProperties.append(SwiftProperty(
                    type: "var",
                    name: param.name,
                    dataType: param.type,
                    defaultValue: param.defaultValue
                ))
                Log.log("Parâmetro de ação encontrado: \(param.name)")
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
            Log.log("Componente nativo encontrado: \(componentName)")
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
                Log.log("Parâmetro de ação encontrado: \(param.name)")
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
                                Log.log("Arquivo de estilos encontrado: \(componentInfo.stylesPath)")
                                
                                // Extrair casos de estilo do arquivo de estilos
                                if let content = readFile(at: componentInfo.stylesPath) {
                                    componentInfo.styleCases = extractStyleCases(from: content)
                                    componentInfo.styleFunctions = extractStyleFunctions(from: content, componentName: componentName)
                                    Log.log("Casos de estilo encontrados: \(componentInfo.styleCases)")
                                    Log.log("Funções de estilo encontradas: \(componentInfo.styleFunctions.map { $0.name })")
                                }
                                break
                            }
                        }
                    } catch {
                        Log.log("Erro ao listar arquivos em \(path): \(error)", level: .error)
                    }
                }
            }
            
            // Se não encontrou style cases ou funções, definir valores padrão
            if componentInfo.styleCases.isEmpty && componentInfo.styleFunctions.isEmpty {
                componentInfo.styleCases = [nativeInfo.defaultStyleCase]
                Log.log("Usando caso de estilo padrão: \(componentInfo.styleCases)")
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
                Log.log("Componente encontrado em: \(basePath)")
                foundPath = basePath
                let typePath = basePath.contains("BaseElements") ? "BaseElements/Natives" : "Components/Customs"
                componentInfo = ComponentInfo(name: componentName, typePath: typePath)
                break
            }
        }
        
        guard let componentInfo = componentInfo, let foundPath = foundPath else {
            Log.log("Componente '\(componentName)' não encontrado. Caminhos verificados: \(possiblePaths)", level: .error)
            return nil
        }
        
        // Localizar arquivos View, Configuration e Styles
        do {
            let files = try FileManager.default.contentsOfDirectory(atPath: foundPath)
            Log.log("Arquivos encontrados no diretório do componente: \(files)")
            
            for file in files {
                let filePath = "\(foundPath)/\(file)"
                Log.log("Verificando arquivo: \(filePath)")
                
                if file.contains("\(componentName)View") {
                    componentInfo.viewPath = filePath
                    Log.log("View encontrada: \(filePath)")
                } else if file.contains("\(componentName)Configuration") {
                    componentInfo.configPath = filePath
                    Log.log("Configuration encontrada: \(filePath)")
                } else if file.contains("\(componentName)Styles") {
                    componentInfo.stylesPath = filePath
                    Log.log("Styles encontrada: \(filePath)")
                }
            }
        } catch {
            Log.log("Erro ao listar arquivos do componente: \(error)", level: .error)
            return componentInfo
        }
        
        // Verificar se encontrou os arquivos necessários
        if componentInfo.viewPath.isEmpty {
            Log.log("View não encontrada para o componente \(componentName)", level: .warning)
        }
        
        // Extrair propriedades, funções de estilo e casos de estilo
        if !componentInfo.viewPath.isEmpty, let content = readFile(at: componentInfo.viewPath) {
            Log.log("Analisando view: \(componentInfo.viewPath)")
            componentInfo.properties = extractProperties(from: content)
            
            // Categorizar propriedades
            let (enumProps, textProps, boolProps, numberProps) = categorizeProperties(componentInfo.properties)
            componentInfo.enumProperties = enumProps
            componentInfo.textProperties = textProps
            componentInfo.boolProperties = boolProps
            componentInfo.numberProperties = numberProps
            
            Log.log("Propriedades extraídas: \(componentInfo.properties.map { $0.name })")
        }
        
        if !componentInfo.stylesPath.isEmpty, let content = readFile(at: componentInfo.stylesPath) {
            Log.log("Analisando arquivo de estilos: \(componentInfo.stylesPath)")
            componentInfo.styleFunctions = extractStyleFunctions(from: content, componentName: componentName)
            
            // Se não encontrou funções de estilo, tenta extrair do StyleCase (para compatibilidade)
            if componentInfo.styleFunctions.isEmpty {
                Log.log("Tentando extrair casos de estilo (StyleCase)")
                componentInfo.styleCases = extractStyleCases(from: content)
                Log.log("Casos de estilo encontrados: \(componentInfo.styleCases)")
            }
        }
        
        // Se for o componente Button, definir valores padrão específicos
        if componentName == "Button" {
            Log.log("Configurando valores específicos para Button")
            if componentInfo.styleCases.isEmpty {
                componentInfo.styleCases = ["contentA", "highlightA", "backgroundD"]
                Log.log("Definindo casos de estilo padrão para Button: \(componentInfo.styleCases)")
            }
        }
        
        return componentInfo
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

}
