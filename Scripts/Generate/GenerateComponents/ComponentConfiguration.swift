import Foundation

// MARK: - Modelos de dados

struct SwiftProperty {
    let type: String // var ou let
    let name: String
    let dataType: String
    let defaultValue: String?
}

protocol ParameterProtocol {
    var name: String { get }
    var type: String { get }
    var defaultValue: String? { get }
}

struct StyleParameter: Hashable, ParameterProtocol {
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

struct InitParameter: Hashable, ParameterProtocol {
    let order: Int
    let hasObfuscatedArgument: Bool
    let isUsedAsBinding: Bool
    let label: String?
    let name: String
    var type: String
    var defaultValue: String?
    let isAction: Bool
}

class ComponentInfo {
    let name: String
    let typePath: String
    
    var viewPath: String = ""
    var stylesPath: String = ""
    
    var hasDefaultSampleText = true
    
    var properties: [SwiftProperty] = []
    var styleCases: [String] = []
    var styleParameters: [StyleConfig] = []
    var styleFunctions: [StyleConfig] = []
    
    var enumProperties: [SwiftProperty] = []
    var textProperties: [SwiftProperty] = []
    var boolProperties: [SwiftProperty] = []
    var numberProperties: [SwiftProperty] = []
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
        let content = content.replacingOccurrences(of: "`", with: "")
        
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
    
    func extractInitParams(from content: String) -> [InitParameter] {
        var initParams: [InitParameter] = []
        
        // Padrão aprimorado para localizar inicializadores públicos
        // Usa uma estratégia diferente para capturar todos os parâmetros, incluindo @escaping closures
        let initPattern = "public\\s+init\\s*\\(([^\\{]*)\\)"
        let initRegex = try! NSRegularExpression(pattern: initPattern, options: [.dotMatchesLineSeparators])
        let initMatches = initRegex.matches(in: content, options: [], range: NSRange(content.startIndex..., in: content))
        
        for match in initMatches {
            guard let paramsRange = Range(match.range(at: 1), in: content) else {
                return []
            }
            
            let paramsStr = String(content[paramsRange]).trimmingCharacters(in: .whitespaces)
            if paramsStr.isEmpty {
                return []
            }
            
            // Extrair os parâmetros usando uma função melhorada para lidar com closures
            let params = extractBalancedParameters(from: paramsStr)
            
            // Log de debug para verificar os parâmetros extraídos
            Log.log("Parâmetros extraídos do init: \(params)", level: .info)
            
            for (index, param) in params.enumerated() {
                // Padrão melhorado para extrair detalhes do parâmetro incluindo @escaping
                let paramPattern = "(?:(\\w+)\\s+)?(@?\\w+)?\\s*(\\w+)\\s*:\\s*([^=]+)(?:\\s*=\\s*(.+))?"
                let paramRegex = try! NSRegularExpression(pattern: paramPattern, options: [])
                
                guard let paramMatch = paramRegex.firstMatch(in: param, options: [], range: NSRange(param.startIndex..., in: param)) else {
                    continue
                }
                
                var label: String? = nil
                if paramMatch.numberOfRanges > 1, let labelRange = Range(paramMatch.range(at: 1), in: param),
                   paramMatch.range(at: 1).location != NSNotFound {
                    label = String(param[labelRange])
                }
                
                // Identificar se temos uma anotação como @escaping
                var annotation: String? = nil
                if paramMatch.numberOfRanges > 2, let annotationRange = Range(paramMatch.range(at: 2), in: param),
                   paramMatch.range(at: 2).location != NSNotFound {
                    annotation = String(param[annotationRange])
                }
                
                var param = param.replacingOccurrences(of: "\n", with: "").trimmingCharacters(in: .whitespaces)
                guard let nameRange = Range(paramMatch.range(at: 3), in: param),
                      let typeRange = Range(paramMatch.range(at: 4), in: param) else {
                    continue
                }
                
                let name = String(param[nameRange])
                var type = String(param[typeRange]).trimmingCharacters(in: .whitespaces)
                
                // Se temos uma anotação, incluí-la no tipo
                if let annotation = annotation, !annotation.isEmpty {
                    type = "\(annotation) \(type)"
                }
                
                var defaultValue: String? = nil
                if paramMatch.numberOfRanges > 5, let defaultValueRange = Range(paramMatch.range(at: 5), in: param),
                   paramMatch.range(at: 5).location != NSNotFound {
                    defaultValue = String(param[defaultValueRange]).trimmingCharacters(in: .whitespaces)
                }
                
                // Determinar se é um parâmetro de closure/ação
                let isAction = type.contains("->")
                
                var isUsedAsBinding = false
                
                if type.contains("Binding<") {
                    // Extrair o conteúdo entre Binding< e o fechamento correspondente >
                    var depth = 0
                    let startIndex = type.index(type.range(of: "Binding<")!.upperBound, offsetBy: 0)
                    var endIndex = startIndex
                    
                    // Percorrer a string para encontrar o ">" correspondente
                    for (i, char) in type[startIndex...].enumerated() {
                        if char == "<" {
                            depth += 1
                        } else if char == ">" {
                            if depth == 0 {
                                endIndex = type.index(startIndex, offsetBy: i)
                                break
                            }
                            depth -= 1
                        }
                    }
                    
                    // Extrair o conteúdo interno do Binding
                    type = String(type[startIndex..<endIndex])
                    isUsedAsBinding = true
                }
                
                if type.contains("@escaping") {
                    type = type.replacingOccurrences(of: "@escaping ", with: "").replacingOccurrences(of: "\n", with: "")
                    type = "(\(type))"
                    defaultValue = "{}"
                }
                
                // Verificar se o tipo parece ser um enum e tentar encontrar um valor padrão
                if defaultValue == nil && (type.hasSuffix("Case") || type.hasSuffix("Enum")) {
                    if let enumDefaultValue = findEnumDefaultValue(type) {
                        defaultValue = ".\(enumDefaultValue)"
                        Log.log("Valor padrão para enum \(type) encontrado: \(defaultValue!)", level: .info)
                    }
                }
                
                if let value = defaultValue, value.contains(".constant(") {
                    defaultValue = value.replacingOccurrences(of: ".constant(", with: "").replacingOccurrences(of: ")", with: "")
                }
                
                initParams.append(InitParameter(
                    order: index,
                    hasObfuscatedArgument: (label ?? "").starts(with: "_"),
                    isUsedAsBinding: isUsedAsBinding,
                    label: label,
                    name: name,
                    type: type,
                    defaultValue: defaultValue,
                    isAction: isAction
                ))
            }
        }
        var filteredInitParams: [InitParameter] = []
        
        initParams.forEach { param in
            // Tratamento para Imagem em String
            if filteredInitParams.contains(where: { $0.name == param.name && $0.type == "String" && param.type == "SFSymbol" }), var foundInitParam = filteredInitParams.first(where: { $0.name == param.name && $0.type == "String" }) {
                filteredInitParams.removeAll(where: { $0.name == param.name && $0.type == "String" })
                foundInitParam.defaultValue = "\"figure.run\""
                foundInitParam.type = "StringImageEnum"
                filteredInitParams.append(foundInitParam)
            }
            if filteredInitParams.contains(where: { $0.name == param.name }) == false && param.type.contains("StyleConfiguration") == false {
                filteredInitParams.append(param)
            }
        }
        return filteredInitParams
    }
    
    // Nova função para extrair parâmetros de forma equilibrada, respeitando parênteses aninhados
    func extractBalancedParameters(from string: String) -> [String] {
        var parameters: [String] = []
        var currentParam = ""
        var parenLevel = 0
        var bracketLevel = 0
        var braceLevel = 0
        var inString = false
        
        for char in string {
            // Gerenciar strings para evitar confusão com caracteres dentro de strings
            if char == "\"" {
                inString = !inString
                currentParam.append(char)
                continue
            }
            
            // Se estamos dentro de uma string, apenas adicione o caractere
            if inString {
                currentParam.append(char)
                continue
            }
            
            // Gerenciar níveis de aninhamento
            switch char {
            case "(":
                parenLevel += 1
                currentParam.append(char)
            case ")":
                parenLevel -= 1
                currentParam.append(char)
            case "[":
                bracketLevel += 1
                currentParam.append(char)
            case "]":
                bracketLevel -= 1
                currentParam.append(char)
            case "{":
                braceLevel += 1
                currentParam.append(char)
            case "}":
                braceLevel -= 1
                currentParam.append(char)
            case ",":
                // Separar apenas se estamos no nível superior (não dentro de parênteses, colchetes ou chaves)
                if parenLevel == 0 && bracketLevel == 0 && braceLevel == 0 {
                    parameters.append(currentParam.trimmingCharacters(in: .whitespaces))
                    currentParam = ""
                } else {
                    currentParam.append(char)
                }
            default:
                currentParam.append(char)
            }
        }
        
        // Adicionar o último parâmetro se houver um
        if !currentParam.trimmingCharacters(in: .whitespaces).isEmpty {
            parameters.append(currentParam.trimmingCharacters(in: .whitespaces))
        }
        
        return parameters
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
    
    func findComponentFiles(_ componentName: String) -> ComponentInfo? {
        // Verificar primeiro se é um componente nativo
        if let nativeComponent = NATIVE_COMPONENTS[componentName] {
            return findNativeComponent(nativeComponent, name: componentName)
        }
        
        return findCustomComponent(componentName)
    }
    
    func findNativeComponent(_ nativeComponent: NativeComponent, name: String) -> ComponentInfo {
        Log.log("Componente nativo encontrado: \(name)")
        var componentInfo = ComponentInfo(name: name, typePath: nativeComponent.typePath)
        componentInfo.isNative = true
        componentInfo.contextualModule = nativeComponent.contextualModule
        
        // Converter init params do formato nativo para o formato interno
        for (index, param) in nativeComponent.initParams.enumerated() {
            var isUsedAsBinding = false
            var type = param.type
            if param.type.contains("Binding") {
                type = param.type.replacingOccurrences(of: "Binding<", with: "").replacingOccurrences(of: ">", with: "")
                isUsedAsBinding = true
            }
            componentInfo.publicInitParams.append(
                InitParameter(
                    order: index,
                    hasObfuscatedArgument: (param.label ?? "").starts(with: "_"),
                    isUsedAsBinding: isUsedAsBinding,
                    label: param.label,
                    name: param.name,
                    type: type,
                    defaultValue: param.defaultValue,
                    isAction: param.isAction
                )
            )
        }
        
        componentInfo.exampleCode = nativeComponent.exampleCode
        componentInfo.generateCode = nativeComponent.generateCode
        
        // Se for componente nativo, procurar apenas pelo arquivo de estilos
        let possiblePaths = [
            "\(COMPONENTS_PATH)/BaseElements/Natives/\(name)"
        ]
        
        for path in possiblePaths {
            if FileManager.default.fileExists(atPath: path) {
                do {
                    let files = try FileManager.default.contentsOfDirectory(atPath: path)
                    for file in files {
                        if let styledComponentInfo = configStyles(
                            componentInfo: componentInfo,
                            name: name,
                            file: file,
                            path: path
                        ) {
                            componentInfo = styledComponentInfo
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
    
    func findCustomComponent(_ name: String) -> ComponentInfo? {
        // Para componentes não nativos, seguir o fluxo normal
        var componentInfo: ComponentInfo?

        let possiblePaths = [
            "\(COMPONENTS_PATH)/BaseElements/Customs/\(name)",
            "\(COMPONENTS_PATH)/Components/Customs/\(name)",
            "\(COMPONENTS_PATH)/Templates/\(name)",
        ]
        
        // Verificar se algum dos caminhos possíveis existe
        var foundPath: String?
        for basePath in possiblePaths {
            if FileManager.default.fileExists(atPath: basePath) {
                Log.log("Componente encontrado em: \(basePath)")
                foundPath = basePath
                var typePath = "BaseElements/Customs"
                if basePath.contains("BaseElements/Customs") {
                    typePath = "BaseElements/Customs"
                }
                if basePath.contains("Components/Customs") {
                    typePath = "Components/Customs"
                }
                componentInfo = ComponentInfo(name: name, typePath: typePath)
                break
            }
        }
        
        guard var componentInfo = componentInfo, let foundPath = foundPath else {
            Log.log("Componente '\(name)' não encontrado. Caminhos verificados: \(possiblePaths)", level: .error)
            return nil
        }
        
        // Localizar arquivos View, Configuration e Styles
        do {
            let files = try FileManager.default.contentsOfDirectory(atPath: foundPath)
            Log.log("Arquivos encontrados no diretório do componente: \(files)")
            
            for file in files {
                let filePath = "\(foundPath)/\(file)"
                Log.log("Verificando arquivo: \(filePath)")
                
                if file.contains("\(name).swift") {
                    componentInfo.viewPath = filePath
                    componentInfo.hasDefaultSampleText = false
                    Log.log("View encontrada: \(filePath)")
                    if let content = readFile(at: componentInfo.viewPath) {
                        componentInfo.publicInitParams = extractInitParams(from: content)
                        componentInfo.exampleCode = """
                        \(name)(\(componentInfo.publicInitParams.joined()))
                        """
                        componentInfo.generateCode = """
                        \(name)(\(componentInfo.publicInitParams.sampleJoined()))
                        """
                    }
                }
                if let styledComponentInfo = configStyles(
                    componentInfo: componentInfo,
                    name: name,
                    file: file,
                    path: foundPath
                ) {
                    componentInfo = styledComponentInfo
                    Log.log("Styles encontrada: \(filePath)")
                }
            }
        } catch {
            Log.log("Erro ao listar arquivos do componente: \(error)", level: .error)
            return componentInfo
        }

        return componentInfo
    }
    
    func configStyles(componentInfo: ComponentInfo, name: String, file: String, path: String) -> ComponentInfo? {
        if file.contains("\(name)Styles.swift") {
            componentInfo.stylesPath = "\(path)/\(file)"
            Log.log("Arquivo de estilos encontrado: \(componentInfo.stylesPath)")
            
            // Extrair casos de estilo do arquivo de estilos
            if let content = readFile(at: componentInfo.stylesPath) {
                componentInfo.styleCases = extractStyleCases(from: content)
                componentInfo.styleFunctions = extractStyleFunctions(from: content, componentName: name)
                componentInfo.styleParameters = extractStyleParameters(from: content, componentName: name)
                Log.log("Parametros da função de estilo encontrados: \(componentInfo.styleParameters.map { $0.name })")
                Log.log("Casos de estilo encontrados: \(componentInfo.styleCases)")
                Log.log("Funções de estilo encontradas: \(componentInfo.styleFunctions.map { $0.name })")
            }
        }
        return nil
    }
    
    func extractStyleCases(from content: String) -> [String] {
        var cases = Set<String>() // Uso Set para evitar duplicatas
        
        // Procura por enum com nome que termina com StyleCase
        let enumPattern = "enum\\s+(\\w+StyleCase)[^{]*\\{"
        let enumRegex = try! NSRegularExpression(pattern: enumPattern, options: [])
        
        // Tentar encontrar a declaração do enum
        let enumMatches = enumRegex.matches(in: content, options: [], range: NSRange(content.startIndex..., in: content))
        
        for enumMatch in enumMatches {
            guard let enumStartRange = Range(enumMatch.range, in: content) else {
                continue
            }
            
            // Encontrar o fim do bloco do enum contando chaves
            let blockStart = content.index(after: content.index(enumStartRange.upperBound, offsetBy: -1))
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
    
    
    
    
    /// METODOS NAO USADOS MAS QUE PODEM SER UTEIS
    
    /// olha pras propriedades da classe
    func extractProperties(from content: String) -> [InitParameter] {
        var properties: [InitParameter] = []
        
        // Padrão para localizar propriedades
        let pattern = "(var|let)\\s+(\\w+)\\s*:\\s*([^{=\\n]+)(?:\\s*=\\s*([^{\\n]+))?"
        let regex = try! NSRegularExpression(pattern: pattern, options: [])
        let matches = regex.matches(in: content, options: [], range: NSRange(content.startIndex..., in: content))
        
        for (index, match) in matches.enumerated() {
            guard let propLabelRange = Range(match.range(at: 1), in: content),
                  let propNameRange = Range(match.range(at: 2), in: content),
                  let propTypeRange = Range(match.range(at: 3), in: content) else {
                continue
            }
            
            let propLabel = String(content[propLabelRange])
            let propName = String(content[propNameRange])
            var propType = String(content[propTypeRange]).trimmingCharacters(in: .whitespaces)
            
            var defaultValue: String? = nil
            if match.numberOfRanges > 4, let defaultValueRange = Range(match.range(at: 4), in: content) {
                defaultValue = String(content[defaultValueRange]).trimmingCharacters(in: .whitespaces)
            }
            
            if propName == "body" && propType == "some View" {
                continue
            }
            let isAction = propType.contains("->")
            
            var isUsedAsBinding = false
            
            if propType.contains("Binding") {
                propType = propType.replacingOccurrences(of: "Binding<", with: "").replacingOccurrences(of: ">", with: "")
                isUsedAsBinding = true
            }
            
            properties.append(
                InitParameter(
                    order: index,
                    hasObfuscatedArgument: propLabel.starts(with: "_"),
                    isUsedAsBinding: isUsedAsBinding,
                    label: propLabel,
                    name: propName,
                    type: propType,
                    defaultValue: defaultValue,
                    isAction: isAction
                )
            )
        }
        
        return properties
    }
}

// MARK: - Funções para buscar enums

extension ComponentConfiguration {
    func findEnumDefaultValue(_ enumTypeName: String) -> String? {
        // Locais comuns onde os enums podem estar definidos
        let searchPaths = [
            "\(COMPONENTS_PATH)/BaseElements/Customs",
            "\(COMPONENTS_PATH)/Components/Customs",
            "\(COMPONENTS_PATH)/Templates",
            "\(COMPONENTS_PATH)/BaseElements/Natives",
            "\(COMPONENTS_PATH)/Enums",
            "\(COMPONENTS_PATH)/Utils",
            "\(COMPONENTS_PATH)/Styles"
        ]
        
        // Primeiro tenta encontrar um arquivo específico para o enum
        for basePath in searchPaths {
            do {
                let files = try FileManager.default.contentsOfDirectory(atPath: basePath)
                
                // Tenta encontrar um arquivo que contenha o nome do enum
                for file in files {
                    let filePath = "\(basePath)/\(file)"
                    
                    if file.contains(enumTypeName) {
                        Log.log("Verificando arquivo específico para enum \(enumTypeName): \(filePath)", level: .info)
                        if let content = readFile(at: filePath), 
                           let firstCase = extractFirstEnumCase(from: content, enumTypeName: enumTypeName) {
                            return firstCase
                        }
                    }
                }
                
                // Se não encontrou arquivo específico, busca em todos os arquivos swift
                for file in files where file.hasSuffix(".swift") {
                    let filePath = "\(basePath)/\(file)"
                    if let content = readFile(at: filePath), 
                       let firstCase = extractFirstEnumCase(from: content, enumTypeName: enumTypeName) {
                        Log.log("Enum \(enumTypeName) encontrado em: \(filePath)", level: .info)
                        return firstCase
                    }
                }
                
                // Buscar em subdiretórios de um nível
                for dir in files {
                    let dirPath = "\(basePath)/\(dir)"
                    var isDirectory: ObjCBool = false
                    
                    if FileManager.default.fileExists(atPath: dirPath, isDirectory: &isDirectory) && isDirectory.boolValue {
                        do {
                            let subFiles = try FileManager.default.contentsOfDirectory(atPath: dirPath)
                            
                            for subFile in subFiles where subFile.hasSuffix(".swift") {
                                let subFilePath = "\(dirPath)/\(subFile)"
                                if let content = readFile(at: subFilePath),
                                   let firstCase = extractFirstEnumCase(from: content, enumTypeName: enumTypeName) {
                                    Log.log("Enum \(enumTypeName) encontrado em: \(subFilePath)", level: .info)
                                    return firstCase
                                }
                            }
                        } catch {
                            Log.log("Erro ao listar subdiretório \(dirPath): \(error)", level: .error)
                        }
                    }
                }
            } catch {
                Log.log("Erro ao listar diretório \(basePath): \(error)", level: .error)
            }
        }
        
        Log.log("Não foi encontrado valor padrão para o enum \(enumTypeName)", level: .warning)
        return nil
    }
    
    func extractFirstEnumCase(from content: String, enumTypeName: String) -> String? {
        // Padrão melhorado para encontrar declaração do enum - agora inclui modificadores de acesso e atributos
        let enumPattern = "(?:public|private|internal|fileprivate|open)?\\s*(?:@\\w+\\s+)*enum\\s+\(enumTypeName)\\s*(?::|,|\\{)"
        let enumRegex = try! NSRegularExpression(pattern: enumPattern, options: [])
        
        guard let enumMatch = enumRegex.firstMatch(in: content, options: [], range: NSRange(content.startIndex..., in: content)),
              let enumRange = Range(enumMatch.range, in: content) else {
            return nil
        }
        
        // Encontra o início do bloco do enum
        let blockStart = content.index(after: content[enumRange].lastIndex(of: "{") ?? enumRange.upperBound)
        var braceCount = 1
        var blockEnd = blockStart
        
        // Encontra o fim do bloco do enum
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
        
        let enumContent = String(content[blockStart..<blockEnd])
        
        // Procura pelo primeiro caso do enum
        let casePattern = "case\\s+(\\w+)"
        let caseRegex = try! NSRegularExpression(pattern: casePattern, options: [])
        
        guard let caseMatch = caseRegex.firstMatch(in: enumContent, options: [], range: NSRange(enumContent.startIndex..., in: enumContent)),
              let caseRange = Range(caseMatch.range(at: 1), in: enumContent) else {
            
            // Tenta um padrão alternativo para casos em uma única linha
            let multiCasePattern = "case\\s+([^,\\s]+)"
            let multiCaseRegex = try! NSRegularExpression(pattern: multiCasePattern, options: [])
            
            guard let multiCaseMatch = multiCaseRegex.firstMatch(in: enumContent, options: [], range: NSRange(enumContent.startIndex..., in: enumContent)),
                  let multiCaseRange = Range(multiCaseMatch.range(at: 1), in: enumContent) else {
                return nil
            }
            
            return String(enumContent[multiCaseRange])
        }
        
        return String(enumContent[caseRange])
    }
}

extension Array where Element == InitParameter {
    func joined() -> String {
        sorted(by: {$0.order < $1.order }).enumerated().map { index, item in
            var parameterString = "\(item.name): \(item.name)"
            if item.hasObfuscatedArgument {
                parameterString = item.name
            }
            if item.isUsedAsBinding {
                parameterString = "\(item.name): $\(item.name)"
            }
            return index < count - 1 ? "\(parameterString)," : parameterString
        }.joined(separator: " ")
    }
    
    func sampleJoined() -> String {
        sorted(by: {$0.order < $1.order }).enumerated().map { index, item in
            
            let parameterType = "\(item.name): "
            var parameterValue = switch item.type {
                
            case "String", "StringImageEnum":
                "\"\\(\(item.name))\""
            case "Bool":
                "\\(\(item.name))"
            case "Int", "Double", "CGFloat":
                "\(item.name)"
            default:
                if item.type.contains("->") {
                    "{}"
                } else {
                    ".\\(\(item.name).rawValue)"
                }
            }
            
            if item.isUsedAsBinding {
                parameterValue = ".constant(\(parameterValue))"
            }
            
            var parameterString = "\(parameterType)\(parameterValue)"
            if item.hasObfuscatedArgument {
                parameterString = parameterValue
            }
            return index < count - 1 ? "\(parameterString)," : parameterString
        }.joined(separator: " ")
    }
}
