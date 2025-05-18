import Foundation

// MARK: - Modelos de dados

struct SwiftProperty {
    let type: String // var ou let
    let name: String
    let dataType: String
    let defaultValue: String?
}

struct StyleParameter: Hashable {
    let order: Int
    let hasObfuscatedArgument: Bool
    let isUsedAsBinding: Bool
    let name: String
    let type: String
    let defaultValue: String?
}

struct StyleConfig {
    let name: String
    let parameters: [StyleParameter]
}

struct InitParameter: Hashable {
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
    var styleParameters: [StyleConfig] = []
    var styleFunctions: [StyleConfig] = []
    
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
    var generateCode: String = ""
    
    var contextualModule: Bool = false
    
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
    
    func extractStyleParameters(from content: String, componentName: String) -> [StyleConfig] {
        var styleConfigs: [StyleConfig] = []
        
        // Log para debug
        Log.log("Extraindo parâmetros de estilo para \(componentName)", level: .info)
        
        // Padrão para localizar extensões que contenham funções de estilo do componente
        let extensionPattern = "public\\s+extension\\s+([^{]*)\\s*\\{[^}]*func\\s+(\\w+)Style\\s*\\(([^\\)]*)\\)"
        let extensionRegex = try! NSRegularExpression(pattern: extensionPattern, options: [.dotMatchesLineSeparators])
        let extensionMatches = extensionRegex.matches(in: content, options: [], range: NSRange(content.startIndex..., in: content))
        
        for match in extensionMatches {
            if match.numberOfRanges < 4 {
                continue
            }
            
            guard let extensionTypeRange = Range(match.range(at: 1), in: content),
                  let functionNameRange = Range(match.range(at: 2), in: content),
                  let paramsRange = Range(match.range(at: 3), in: content) else {
                continue
            }
            
            let extensionType = String(content[extensionTypeRange]).trimmingCharacters(in: .whitespaces)
            let functionName = String(content[functionNameRange]).trimmingCharacters(in: .whitespaces)
            
            // Verificamos se a extensão ou a função corresponde ao componente desejado
            // A função pode ser componenteStyle (ex: textFieldStyle) ou apenas style
            let matchesComponent = extensionType.contains(componentName) ||
            functionName.lowercased() == componentName.lowercased()
            
            if !matchesComponent {
                continue
            }
            
            // Extrair todos os parâmetros da função de estilo
            let paramsString = String(content[paramsRange]).trimmingCharacters(in: .whitespaces)
            var parameters: [StyleParameter] = []
            
            // Precisamos lidar com o primeiro parâmetro de forma especial, pois é o estilo
            let paramsList = splitFunctionParameters(paramsString)
            
            // Ignorar o primeiro parâmetro se for o estilo
            let startIndex = paramsList.isEmpty ? 0 : (paramsList[0].contains("style") || paramsList[0].contains("_ style") ? 1 : 0)
            
            for i in startIndex..<paramsList.count {
                if let styleParam = parseParameter(paramsList[i], index: i) {
                    parameters.append(styleParam)
                }
            }
            
            // Nome do estilo baseado no componente
            let styleConfigName = "default"
            styleConfigs.append(StyleConfig(name: styleConfigName, parameters: parameters))
            
            Log.log("Função de estilo encontrada para \(componentName): \(styleConfigName) com \(parameters.count) parâmetros", level: .info)
            for param in parameters {
                Log.log("- Parâmetro: \(param.name) do tipo \(param.type) \(param.defaultValue != nil ? "com valor padrão: \(param.defaultValue!)" : "")", level: .info)
            }
        }
        
        // Caso não encontre nenhuma configuração de estilo, retorna uma lista vazia
        return styleConfigs
    }
    
    func extractStyleFunctions(from content: String, componentName: String) -> [StyleConfig] {
        var styleFunctions: [StyleConfig] = []
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
    func extractAllStaticFunctionsFromContent(_ content: String) -> [StyleConfig] {
        var styleFunctions: [StyleConfig] = []
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
                        
                        for (index, param) in paramsList.enumerated() {
                            if let styleParam = parseParameter(param, index: index) {
                                parameters.append(styleParam)
                            }
                        }
                    }
                }
                
                styleFunctions.append(StyleConfig(name: funcName, parameters: parameters))
            }
        }
        
        return styleFunctions
    }
    
    func extractFunctionsFromBlock(_ content: String) -> [StyleConfig] {
        var functions: [StyleConfig] = []
        var content = content.replacingOccurrences(of: "`", with: "")
        
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
                    
                    for (index, param) in paramsList.enumerated() {
                        if let styleParam = parseParameter(param, index: index) {
                            parameters.append(styleParam)
                        }
                    }
                }
            }
            
            // Se não houver parâmetros, adicione um padrão para compatibilidade
            //            if parameters.isEmpty {
            //                parameters = [StyleParameter(name: "color", type: "ColorName", defaultValue: nil)]
            //            }
            
            functions.append(StyleConfig(name: funcName, parameters: parameters))
        }
        
        return functions
    }
    
    func parseParameter(_ paramString: String, index: Int) -> StyleParameter? {
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
        var type = String(paramString[typeRange]).trimmingCharacters(in: .whitespaces)
        
        var defaultValue: String? = nil
        if match.numberOfRanges > 3, let defaultValueRange = Range(match.range(at: 3), in: paramString) {
            defaultValue = String(paramString[defaultValueRange]).trimmingCharacters(in: .whitespaces)
        }
        
        var isUsedAsBinding = false
        
        if type.contains("Binding") {
            type = type.replacingOccurrences(of: "Binding<", with: "").replacingOccurrences(of: ">", with: "")
            isUsedAsBinding = true
        }
        
        if defaultValue?.contains(".constant") == true {
            defaultValue = defaultValue?.replacingOccurrences(of: ".constant(", with: "").replacingOccurrences(of: ")", with: "")
        }
        
        return StyleParameter(
            order: index,
            hasObfuscatedArgument: paramString.starts(with: "_"),
            isUsedAsBinding: isUsedAsBinding,
            name: name,
            type: type,
            defaultValue: defaultValue
        )
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
    
    func extractGenericStyleFunctions(from content: String, componentName: String) -> [StyleConfig] {
        var styleFunctions: [StyleConfig] = []
        
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
                    
                    for (index, param) in paramsList.enumerated() {
                        if let styleParam = parseParameter(param, index: index) {
                            parameters.append(styleParam)
                        }
                    }
                }
            }
            
            styleFunctions.append(StyleConfig(name: funcName, parameters: parameters))
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
            componentInfo.contextualModule = nativeInfo.contextualModule
            
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
            componentInfo.generateCode = nativeInfo.generateCode
            
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
                                    componentInfo.styleParameters = extractStyleParameters(from: content, componentName: componentName)
                                    Log.log("Parametros da função de estilo encontrados: \(componentInfo.styleParameters.map { $0.name })")
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
        
        return componentInfo
    }
    
    func extractStyleCases(from content: String) -> [String] {
        var cases = Set<String>() // Uso Set para evitar duplicatas
        
        // Procura por enum com nome que termina com StyleCase
        let enumPattern = "enum\\s+(\\w+StyleCase)[^{]*\\{"
        let enumRegex = try! NSRegularExpression(pattern: enumPattern, options: [])
        
        // Tentar encontrar a declaração do enum
        let enumMatches = enumRegex.matches(in: content, options: [], range: NSRange(content.startIndex..., in: content))
        
        for enumMatch in enumMatches {
            guard let enumNameRange = Range(enumMatch.range(at: 1), in: content),
                  let enumStartRange = Range(enumMatch.range, in: content) else {
                continue
            }
            
            let enumName = String(content[enumNameRange])
            
            // Encontrar o fim do bloco do enum contando chaves
            var blockStart = content.index(after: content.index(enumStartRange.upperBound, offsetBy: -1))
            var braceCount = 1
            var blockEnd = blockStart
            
            while braceCount > 0 && blockEnd < content.endIndex {
                let char = content[blockEnd]
                if char == "{" {
                    braceCount += 1
                } else if char == "}" {
                    braceCount -= 1
                }
                
                if braceCount > 0 {
                    blockEnd = content.index(after: blockEnd)
                }
            }
            
            // Extrai todo o conteúdo do enum, mas paramos antes de qualquer função dentro do enum
            let fullBlockContent = String(content[blockStart..<blockEnd])
            
            // Remover qualquer parte que comece com "func", que seria uma função dentro do enum
            var blockContent = fullBlockContent
            if let funcRange = fullBlockContent.range(of: "\\s+func\\s+", options: .regularExpression) {
                blockContent = String(fullBlockContent[fullBlockContent.startIndex..<funcRange.lowerBound])
            }
            
            // Padrão 1: case a, b, c, d (em uma única linha)
            let multiCasePattern = "case\\s+([^:\\{\\n]+)"
            let multiCaseRegex = try! NSRegularExpression(pattern: multiCasePattern, options: [])
            let multiCaseMatches = multiCaseRegex.matches(in: blockContent, options: [], range: NSRange(blockContent.startIndex..., in: blockContent))
            
            for match in multiCaseMatches {
                guard let caseListRange = Range(match.range(at: 1), in: blockContent) else {
                    continue
                }
                
                let caseList = String(blockContent[caseListRange])
                    .trimmingCharacters(in: .whitespacesAndNewlines)
                
                // Separar casos múltiplos listados na mesma linha (a, b, c)
                let caseNames = caseList.components(separatedBy: ",")
                    .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
                    .filter { !$0.isEmpty && !$0.hasPrefix(".") } // Filtra valores vazios e que começam com ponto
                
                cases.formUnion(caseNames)
            }
            
            // Para casos que estão em linhas separadas, usamos um padrão diferente
            let singleCasePattern = "case\\s+(\\w+)\\s*$"
            let singleCaseRegex = try! NSRegularExpression(pattern: singleCasePattern, options: [.anchorsMatchLines])
            let singleCaseMatches = singleCaseRegex.matches(in: blockContent, options: [], range: NSRange(blockContent.startIndex..., in: blockContent))
            
            for match in singleCaseMatches {
                guard let caseRange = Range(match.range(at: 1), in: blockContent) else {
                    continue
                }
                
                let caseName = String(blockContent[caseRange])
                    .trimmingCharacters(in: .whitespacesAndNewlines)
                
                // Verificar se o caso não está vazio e não começa com ponto
                if !caseName.isEmpty && !caseName.hasPrefix(".") {
                    cases.insert(caseName)
                }
            }
        }
        
        // Se não encontrou casos suficientes, tenta uma abordagem alternativa
        // Procuramos apenas por 'case' seguido de palavra, mas não dentro de uma função
        if cases.count < 2 {
            // Encontrar primeiro todas as funções para excluí-las da busca
            var functionsRanges: [Range<String.Index>] = []
            let funcPattern = "func\\s+\\w+\\s*\\([^)]*\\)\\s*[^{]*\\{"
            let funcRegex = try! NSRegularExpression(pattern: funcPattern, options: [.dotMatchesLineSeparators])
            let funcMatches = funcRegex.matches(in: content, options: [], range: NSRange(content.startIndex..., in: content))
            
            for match in funcMatches {
                guard let matchRange = Range(match.range, in: content) else { continue }
                
                // Encontrar o fim do bloco da função
                var braceCount = 1
                var endIndex = content.index(after: matchRange.upperBound)
                
                while braceCount > 0 && endIndex < content.endIndex {
                    if content[endIndex] == "{" {
                        braceCount += 1
                    } else if content[endIndex] == "}" {
                        braceCount -= 1
                    }
                    
                    if braceCount > 0 {
                        endIndex = content.index(after: endIndex)
                    }
                }
                
                functionsRanges.append(matchRange.lowerBound..<endIndex)
            }
            
            // Agora vamos procurar todos os 'case' que não estejam dentro de funções
            let directCasePattern = "case\\s+(\\w+)(?:\\s*,\\s*(\\w+))*"
            let directCaseRegex = try! NSRegularExpression(pattern: directCasePattern, options: [])
            let directCaseMatches = directCaseRegex.matches(in: content, options: [], range: NSRange(content.startIndex..., in: content))
            
            matchLoop: for match in directCaseMatches {
                guard let matchRange = Range(match.range, in: content) else { continue }
                
                // Verificar se o match está dentro de alguma função
                for funcRange in functionsRanges {
                    if funcRange.contains(matchRange.lowerBound) {
                        continue matchLoop
                    }
                }
                
                // Extrair cada grupo de captura
                for i in 1..<match.numberOfRanges {
                    guard let caseRange = Range(match.range(at: i), in: content),
                            match.range(at: i).location != NSNotFound else { continue }
                    
                    let caseName = String(content[caseRange])
                        .trimmingCharacters(in: .whitespacesAndNewlines)
                    
                    if !caseName.isEmpty && !caseName.hasPrefix(".") {
                        cases.insert(caseName)
                    }
                }
            }
        }
        
        // Log para debug
        Log.log("Casos de estilo extraídos: \(Array(cases).sorted())", level: .info)
        
        return Array(cases).sorted()
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
