import Foundation

struct InitParser {
    let content: String
    let componentName: String
    
    init(content: String, componentName: String) {
        self.content = content
        self.componentName = componentName
    }
    
    
    func extractInitParams() -> [InitParameter] {
        var initParams: [InitParameter] = []
        
        // Padrão aprimorado para localizar inicializadores públicos
        // Usa uma estratégia diferente para capturar todos os parâmetros, incluindo @escaping closures
        let initPattern = "public\\s+init\\s*\\(([^\\{]*)\\)"
        let initRegex = try! NSRegularExpression(pattern: initPattern, options: [.dotMatchesLineSeparators])
        let initMatches = initRegex.matches(in: content, options: [], range: NSRange(content.startIndex..., in: content))
        
        if let match = initMatches.first {
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
            
            // Processar cada parâmetro individualmente
            for (index, paramString) in params.enumerated() {
                let param = paramString.replacingOccurrences(of: "\n", with: " ").trimmingCharacters(in: .whitespaces)
                
                // Nova abordagem: análise baseada em tokens em vez de regex
                let result = parseInitParameter(param, index: index)
                
                if let initParam = result {
                    initParams.append(initParam)
                    Log.log("Parâmetro processado com sucesso: \(initParam.name): \(initParam.component.name)", level: .info)
                } else {
                    Log.log("Falha ao processar parâmetro: \(param)", level: .warning)
                }
            }
        }
        var filteredInitParams: [InitParameter] = []
        
        initParams.forEach { param in
            // Tratamento para Imagem em String
            if filteredInitParams.contains(where: { $0.name == param.name && $0.component.type == .String && param.component.name == "SFSymbol" }), var foundInitParam = filteredInitParams.first(where: { $0.name == param.name && $0.component.type == .String }) {
                filteredInitParams.removeAll(where: { $0.name == param.name && $0.component.type == .String })
                foundInitParam.defaultValue = "\"figure.run\""
                foundInitParam.component.name = "StringImageEnum"
                foundInitParam.component.type = .SFSymbol
                filteredInitParams.append(foundInitParam)
            }
            if filteredInitParams.contains(where: { $0.name == param.name }) == false && param.component.name.contains("StyleConfiguration") == false {
                filteredInitParams.append(param)
            }
        }
        return filteredInitParams
    }
}

fileprivate extension InitParser {
    
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
    
    // Nova função para análise manual de parâmetros de inicialização
    func parseInitParameter(_ paramString: String, index: Int) -> InitParameter? {
        let trimmed = paramString.trimmingCharacters(in: .whitespaces)
        
        // Verificar se é um parâmetro vazio
        if trimmed.isEmpty {
            return nil
        }
        
        // Dividir o parâmetro nas partes principais: label/nome e tipo/valor padrão
        // Exemplo: "_  configuration: DetailedListItemStyleConfiguration"
        // Ou: "title: String = "Default""
        
        // Primeiro, dividimos pelo caractere ':'
        guard let colonIndex = trimmed.firstIndex(of: ":") else {
            Log.log("Formato inválido de parâmetro (sem ':') : \(trimmed)", level: .warning)
            return nil
        }
        
        // Parte antes do ':' pode conter label e nome (ou apenas nome)
        let leftSide = String(trimmed[..<colonIndex]).trimmingCharacters(in: .whitespaces)
        
        // Parte após o ':' contém o tipo e possivelmente um valor padrão
        var rightSide = String(trimmed[trimmed.index(after: colonIndex)...]).trimmingCharacters(in: .whitespaces)
        
        // Separar tipo e valor padrão se houver um '='
        var defaultValue: String? = nil
        if let equalIndex = rightSide.firstIndex(of: "=") {
            let typeSubstring = rightSide[..<equalIndex].trimmingCharacters(in: .whitespaces)
            defaultValue = String(rightSide[rightSide.index(after: equalIndex)...]).trimmingCharacters(in: .whitespaces)
            rightSide = String(typeSubstring)
        }
        
        // Analisar a parte esquerda (label e nome)
        var label: String? = nil
        var name: String
        
        // Se houver um espaço, pode ter um label e um nome
        if let spaceIndex = leftSide.firstIndex(of: " ") {
            let possibleLabel = String(leftSide[..<spaceIndex]).trimmingCharacters(in: .whitespaces)
            let possibleName = String(leftSide[leftSide.index(after: spaceIndex)...]).trimmingCharacters(in: .whitespaces)
            
            // Se ainda houver espaços depois de dividir, significa que temos uma situação mais complexa
            // Por exemplo: "_ configuration" ou "@escaping completion"
            if possibleName.contains(" ") {
                // Dividir em palavras e usar a última como nome
                let words = leftSide.components(separatedBy: .whitespaces).filter { !$0.isEmpty }
                if let lastWord = words.last {
                    name = lastWord
                    // Verificar se há um label (_) ou anotações (@something)
                    if words.first == "_" {
                        label = "_"
                    } else if words.count > 1 {
                        // Possível anotação ou outro contexto - ignoramos
                    }
                } else {
                    name = possibleName // Fallback
                }
            } else {
                // Caso simples com label e nome
                label = possibleLabel
                name = possibleName
            }
        } else {
            // Sem espaços, deve ser apenas o nome
            name = leftSide
        }
        
        // Processar o tipo (parte direita)
        let type = rightSide.trimmingCharacters(in: .whitespaces)
        
        // Verificar tipo vazio
        if type.isEmpty {
            Log.log("Tipo vazio para parâmetro: \(trimmed)", level: .warning)
            return nil
        }
        
        // Verificar se é ação (contém "->")
        let isAction = type.contains("->")
        
        // Verificar se é binding
        var isBinding = false
        var processedType = type
        let component = ComponentFinder(type: type).findComponentType()
        let replacedBinding = getContentInfo(processedType, patternStart: "Binding<")
        isBinding = replacedBinding.success
        if replacedBinding.success {
            processedType = replacedBinding.type
        }
        
        // Processar @escaping e outros modificadores
        if processedType.contains("@escaping") {
            processedType = processedType.replacingOccurrences(of: "@escaping ", with: "")
            if defaultValue == nil {
                defaultValue = "{}"
            }
        }
        
        // Verificação para enums
        if defaultValue == nil && (processedType.hasSuffix("Case") || processedType.hasSuffix("Enum")) {
            if let enumValue = findEnumDefaultValue(processedType) {
                defaultValue = ".\(enumValue)"
            }
        }
        if defaultValue == nil, component.type.complexType {
            if let complexType = findComplexTypeDefaultInfo(processedType) {
                defaultValue = complexType
            }
        }
        
        // Tratar valores .constant()
        if let value = defaultValue, value.contains(".constant(") {
            defaultValue = value.replacingOccurrences(of: ".constant(", with: "").replacingOccurrences(of: ")", with: "")
        }
        
        Log.log("Analisado: nome=\(name), tipo=\(processedType), default=\(String(describing: defaultValue))", level: .info)
        
        return InitParameter(
            order: index,
            hasObfuscatedArgument: (label ?? "").starts(with: "_"),
            isUsedAsBinding: isBinding,
            label: label,
            name: name,
            component: ComponentFinder(type: processedType).findComponentType(),
            defaultValue: defaultValue,
            isAction: isAction
        )
    }
    
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
                        if let content = filePath.readFile(),
                           let firstCase = extractFirstEnumCase(from: content, enumTypeName: enumTypeName) {
                            return firstCase
                        }
                    }
                }
                
                // Se não encontrou arquivo específico, busca em todos os arquivos swift
                for file in files where file.hasSuffix(".swift") {
                    let filePath = "\(basePath)/\(file)"
                    if let content = filePath.readFile(),
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
                                if let content = subFilePath.readFile(),
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
    
    func getContentInfo(_ type: String, patternStart: String) -> (type: String, success: Bool) {
        // Verificar se é binding
        var success = false
        var processedType = type
        
        if type.contains(patternStart) {
            success = true
            // Extração mais segura do tipo dentro do Binding<>
            if let startBracket = type.range(of: patternStart)?.upperBound {
                var depth = 0
                var endIndex = startBracket
                
                for (i, char) in type[startBracket...].enumerated() {
                    if char == "<" {
                        depth += 1
                    } else if char == ">" {
                        if depth == 0 {
                            endIndex = type.index(startBracket, offsetBy: i)
                            break
                        }
                        depth -= 1
                    }
                }
                
                processedType = String(type[startBracket..<endIndex])
            } else {
                // Fallback se não conseguirmos extrair o conteúdo do Binding
                processedType = type.replacingOccurrences(of: patternStart, with: "").replacingOccurrences(of: ">", with: "")
            }
        }
        return(processedType, success)
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

/// Estrutura para armazenar informações sobre uma propriedade de struct/classe
struct ComplexTypeProperty {
    let name: String
    let type: String
    let defaultValue: String?
}

/// Extension para ComponentConfiguration com métodos para buscar struct/class
fileprivate extension InitParser {
    /// Encontra informações padrão para instanciar um tipo complexo (struct ou classe)
    func findComplexTypeDefaultInfo(_ typeName: String) -> String? {
        // Locais comuns onde os tipos complexos podem estar definidos
        let searchPaths = [
            "\(COMPONENTS_PATH)/BaseElements/Customs",
            "\(COMPONENTS_PATH)/Components/Customs",
            "\(COMPONENTS_PATH)/Templates",
            "\(COMPONENTS_PATH)/BaseElements/Natives",
            "\(COMPONENTS_PATH)/Models",
            "\(COMPONENTS_PATH)/Utils",
            "\(COMPONENTS_PATH)/Styles"
        ]
        
        // Buscar o tipo complexo em todos os caminhos possíveis
        for basePath in searchPaths {
            if let foundInfo = searchForComplexTypeValue(typeName, in: basePath) {
                return foundInfo
            }
        }
        
        // Se não encontrou, cria uma instância padrão com o inicializador padrão
        Log.log("Não foi encontrada informação específica para o tipo \(typeName), usando inicializador padrão", level: .warning)
        return "\(typeName)()"
    }
    
    /// Busca um tipo complexo em um caminho específico
    func searchForComplexTypeValue(_ typeName: String, in basePath: String) -> String? {
        if let content = searchForComplexType(typeName, in: basePath), let typeInfo = extractComplexTypeInfo(from: content, typeName: typeName) {
            return generateDefaultInitialization(typeName, from: typeInfo)
        }
        return nil
        
    }
    
    func searchForComplexType(_ typeName: String, in basePath: String) -> String? {
        do {
            let files = try FileManager.default.contentsOfDirectory(atPath: basePath)
            
            // Primeiro, procurar arquivos que tenham o nome do tipo
            for file in files where file.contains(typeName) && file.hasSuffix(".swift") {
                let filePath = "\(basePath)/\(file)"
                Log.log("Verificando arquivo específico para tipo \(typeName): \(filePath)", level: .info)
                if let content = filePath.readFile() {
                    return content
                }
            }
            
            // Se não encontrar, procurar em todos os arquivos Swift
            for file in files where file.hasSuffix(".swift") {
                let filePath = "\(basePath)/\(file)"
                if let content = filePath.readFile() {
                    Log.log("Tipo \(typeName) encontrado em: \(filePath)", level: .info)
                    return content
                }
            }
            
            // Buscar em subdiretórios de um nível
            for dir in files {
                let dirPath = "\(basePath)/\(dir)"
                var isDirectory: ObjCBool = false
                
                if FileManager.default.fileExists(atPath: dirPath, isDirectory: &isDirectory) && isDirectory.boolValue {
                    do {
                        let subFiles = try FileManager.default.contentsOfDirectory(atPath: dirPath)
                        
                        // Primeiro procura arquivos com nome correspondente
                        for subFile in subFiles where subFile.contains(typeName) && subFile.hasSuffix(".swift") {
                            let subFilePath = "\(dirPath)/\(subFile)"
                            if let content = subFilePath.readFile() {
                                Log.log("Tipo \(typeName) encontrado em: \(subFilePath)", level: .info)
                                return content
                            }
                        }
                        
                        // Depois procura em todos os arquivos Swift
                        for subFile in subFiles where subFile.hasSuffix(".swift") {
                            let subFilePath = "\(dirPath)/\(subFile)"
                            if let content = subFilePath.readFile() {
                                Log.log("Tipo \(typeName) encontrado em: \(subFilePath)", level: .info)
                                return content
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
        
        return nil
    }
    
    /// Extrai informações sobre um tipo complexo de um arquivo
    func extractComplexTypeInfo(from content: String, typeName: String) -> [ComplexTypeProperty]? {
        // Padrão para encontrar a definição do tipo (struct ou class)
        let typePattern = "(?:public|private|internal|fileprivate|open)?\\s*(?:struct|class)\\s+\(typeName)\\b"
        let typeRegex = try! NSRegularExpression(pattern: typePattern, options: [])
        
        guard let typeMatch = typeRegex.firstMatch(in: content, options: [], range: NSRange(content.startIndex..., in: content)),
              let typeRange = Range(typeMatch.range, in: content) else {
            return nil
        }
        
        // Encontrar o bloco delimitado por chaves
        var openBraceIndex: String.Index?
        var braceCount = 0
        var currentIndex = typeRange.upperBound
        
        // Encontra a primeira chave de abertura
        while currentIndex < content.endIndex {
            if content[currentIndex] == "{" {
                if openBraceIndex == nil {
                    openBraceIndex = currentIndex
                }
                braceCount += 1
            } else if content[currentIndex] == "}" {
                braceCount -= 1
                if braceCount == 0 && openBraceIndex != nil {
                    // Encontramos o fim do bloco
                    let blockContent = content[content.index(after: openBraceIndex!)...currentIndex]
                    return extractPropertiesFromTypeBlock(String(blockContent))
                }
            }
            currentIndex = content.index(after: currentIndex)
        }
        
        return nil
    }
    
    /// Extrai propriedades de um bloco de código de struct/classe
    func extractPropertiesFromTypeBlock(_ blockContent: String) -> [ComplexTypeProperty] {
        var properties: [ComplexTypeProperty] = []
        
        // Padrão para encontrar propriedades: let/var nome: tipo [= valorPadrão]
        let propertyPattern = "(let|var)\\s+(\\w+)\\s*:\\s*([^=\\n{]+)(?:\\s*=\\s*([^\\n{]+))?"
        let propertyRegex = try! NSRegularExpression(pattern: propertyPattern, options: [])
        let matches = propertyRegex.matches(in: blockContent, options: [], range: NSRange(blockContent.startIndex..., in: blockContent))
        
        for match in matches {
            guard match.numberOfRanges >= 3,
                  let nameRange = Range(match.range(at: 2), in: blockContent),
                  let typeRange = Range(match.range(at: 3), in: blockContent) else {
                continue
            }
            
            let name = String(blockContent[nameRange]).trimmingCharacters(in: .whitespaces)
            let type = String(blockContent[typeRange]).trimmingCharacters(in: .whitespaces)
            
            var defaultValue: String? = nil
            if match.numberOfRanges > 4, let defaultValueRange = Range(match.range(at: 4), in: blockContent) {
                defaultValue = String(blockContent[defaultValueRange]).trimmingCharacters(in: .whitespaces)
            }
            
            // Determinar um valor padrão apropriado baseado no tipo
            if defaultValue == nil {
                defaultValue = determineDefaultValueForType(type)
            }
            
            properties.append(ComplexTypeProperty(name: name, type: type, defaultValue: defaultValue))
        }
        
        return properties
    }
    
    /// Gera um código para inicializar um tipo complexo com base em suas propriedades
    func generateDefaultInitialization(_ typeName: String, from properties: [ComplexTypeProperty]) -> String {
        if properties.isEmpty {
            return "\(typeName)()"
        }
        
        let propertyAssignments = properties.map { prop in
            let value = prop.defaultValue ?? determineDefaultValueForType(prop.type)
            return "\(prop.name): \(value)"
        }.joined(separator: ", ")
        
        return "\(typeName)(\(propertyAssignments))"
    }
    
    /// Determina um valor padrão apropriado para um tipo específico
    func determineDefaultValueForType(_ type: String) -> String {
        let trimmedType = type.trimmingCharacters(in: .whitespaces)
        
        if trimmedType.hasSuffix("?") {
            return "nil"
        }
        
        switch trimmedType {
        case "String":
            return "\"\""
        case "Int", "Float", "Double", "CGFloat":
            return "0"
        case "Bool":
            return "false"
        case let arrayType where arrayType.hasPrefix("[") && arrayType.hasSuffix("]"):
            return "[]"
        case let dictType where dictType.hasPrefix("[") && dictType.contains(":"):
            return "[:]"
        default:
            // Se for um tipo personalizado
            if trimmedType.first?.isUppercase == true &&
                !trimmedType.contains("->") &&
                !trimmedType.contains("<") {
                return "\(trimmedType)()"
            }
            return "nil"
        }
    }
}
