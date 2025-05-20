import Foundation

/// Estrutura para armazenar informações sobre uma propriedade de struct/classe
struct ComplexTypeProperty {
    let name: String
    let type: String
    let defaultValue: String?
}

/// Extension para ComponentConfiguration com métodos para buscar struct/class
extension ComponentConfiguration {
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
    
    /// Busca um tipo complexo em um caminho específico
    func searchForComplexTypeValue(_ typeName: String, in basePath: String) -> String? {
        if let content = searchForComplexType(typeName, in: basePath), let typeInfo = extractComplexTypeInfo(from: content, typeName: typeName) {
            return generateDefaultInitialization(typeName, from: typeInfo)
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
    
    /// Busca e extrai informações sobre o inicializador de uma struct/classe
    func extractInitializerInfo(from content: String, typeName: String) -> [(label: String?, paramName: String, paramType: String)]? {
        // Padrão para encontrar inicializadores públicos
        let initPattern = "(?:public|open)\\s+init\\s*\\(([^\\{]*)\\)"
        let initRegex = try! NSRegularExpression(pattern: initPattern, options: [.dotMatchesLineSeparators])
        let initMatches = initRegex.matches(in: content, options: [], range: NSRange(content.startIndex..., in: content))
        
        if let initMatch = initMatches.first,
           let paramsRange = Range(initMatch.range(at: 1), in: content) {
            let paramsStr = String(content[paramsRange]).trimmingCharacters(in: .whitespaces)
            
            // Extrair os parâmetros do inicializador
            let params = extractBalancedParameters(from: paramsStr)
            
            var result: [(label: String?, paramName: String, paramType: String)] = []
            
            for param in params {
                let trimmed = param.trimmingCharacters(in: .whitespaces)
                if let colonIndex = trimmed.firstIndex(of: ":") {
                    let leftSide = String(trimmed[..<colonIndex]).trimmingCharacters(in: .whitespaces)
                    let rightSide = String(trimmed[trimmed.index(after: colonIndex)...])
                        .trimmingCharacters(in: .whitespaces)
                        .split(separator: "=")[0]
                        .trimmingCharacters(in: .whitespaces)
                    
                    // Processar o lado esquerdo (label/nome)
                    var label: String? = nil
                    var name: String
                    
                    if leftSide.contains(" ") {
                        let components = leftSide.split(separator: " ").map { String($0) }
                        label = components[0]
                        name = components[1]
                    } else {
                        name = leftSide
                    }
                    
                    result.append((label: label, paramName: name, paramType: rightSide))
                }
            }
            
            return result
        }
        
        return nil
    }
    
    /// Detecta se um tipo é uma struct/classe complexa
    func isComplexType(_ typeName: String) -> Bool {
        let primitiveTypes = ["String", "Int", "Bool", "Double", "Float", "CGFloat", "Date", "Data"]
        return !primitiveTypes.contains(typeName) &&
        !typeName.contains("->") &&
        !typeName.contains("[") &&
        !typeName.isEmpty &&
        typeName.first?.isUppercase == true &&
        !typeName.hasSuffix("Case") &&
        !typeName.hasSuffix("Enum")
    }
}
