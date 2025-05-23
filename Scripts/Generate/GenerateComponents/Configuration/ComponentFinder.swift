import Foundation

protocol ComponentProtocol: Equatable {
    var name: String { get set }
    var type: ComponentType { get set }
}

struct ClassComponent: ComponentProtocol {
    var name: String
    var type: ComponentType = .class
}

struct StructComponent: ComponentProtocol {
    var name: String
    var type: ComponentType = .struct
}

struct EnumComponent: ComponentProtocol {
    var name: String
    var type: ComponentType = .enum
}

struct ProtocolComponent: ComponentProtocol {
    var name: String
    var type: ComponentType = .protocol
}

struct ExtensionComponent: ComponentProtocol {
    var name: String
    var type: ComponentType = .extension
}

struct TypealiasComponent: ComponentProtocol {
    var name: String
    var type: ComponentType = .typealias
}

struct PrimitiveComponent: ComponentProtocol {
    var name: String
    var type: ComponentType = .Primitive
}

struct CustomComponent: ComponentProtocol {
    var name: String
    var type: ComponentType
}

struct ClosureComponent: ComponentProtocol {
    var name: String
    var type: ComponentType = .Closure
}

struct NotFoundComponent: ComponentProtocol {
    var name: String = "notFound"
    var type: ComponentType = .notFound
}

enum ComponentType: String, Equatable, CaseIterable {
    case `class`
    case `struct`
    case `enum`
    case `protocol`
    case `extension`
    case `typealias`
    case StringImageEnum
    case Primitive
    case ColorName
    case FontName
    case SFSymbol
    case Closure
    case Int, UInt, Int8, UInt8, Int16, UInt16, Int32, UInt32, Int64, UInt64, Float, Double, Bool, String, Character, Void, Optional, Array, Dictionary, Set, Data, Date, URL, CGFloat
    case notFound
    
    var complexType: Bool {
        self == .class || self == .struct
    }
}

class ComponentFinder {
    private let primitiveTypes: Set<ComponentType> = [
        .Int, .UInt, .Int8, .UInt8, .Int16, .UInt16, .Int32, .UInt32, .Int64, .UInt64,
        .Float, .Double, .Bool, .String, .Character,
        .Void, .Optional, .Array, .Dictionary, .Set,
        .Data, .Date, .URL, .CGFloat
    ]
    
    private let coreEnumTypes: Set<ComponentType> = [
        .ColorName, .FontName
    ]
    
    // Store found components during scanning
    private var foundComponents: [String: any ComponentProtocol] = [:]
    
    let type: String
    
    init(type: String) {
        self.type = type
    }
    
    let scan = Scan()
    
    // Find component type by name by scanning a directory recursively
    func findComponentType() -> any ComponentProtocol {
        let searchPaths = [
            "\(COMPONENTS_PATH)",
        ]
        
        // First check if it's a primitive type
        if let primitiveType = primitiveTypes.first(where: { $0.rawValue == type }) {
            return PrimitiveComponent(name: type, type: primitiveType)
        }
        
        if let coreType = coreEnumTypes.first(where: { $0.rawValue == type }) {
            return EnumComponent(name: type, type: coreType)
        }
        
        if let customType = ComponentType.allCases.first(where: { $0.rawValue == type }) {
            return CustomComponent(name: type, type: customType)
        }
        
        if type.contains("->") || type.contains("escaping") {
            return ClosureComponent(name: type)
        }
        
        // Try to find the component by scanning the directory
        for basePath in searchPaths {
            let filePaths = scan.scanDirectory(at: basePath, type: type)
            
            for filePath in filePaths {
                if let fileContent = try? String(contentsOfFile: filePath) {
                    scanSwiftFile(at: fileContent)
                }
            }
            
            // Check if we found the component
            if let componentType = foundComponents[type] {
                return componentType
            }
        }
        
        return NotFoundComponent()
    }
    
    // Scan a Swift file for component declarations
    private func scanSwiftFile(at content: String) {
        // Remove comments to avoid false positives
        let contentWithoutComments = content.removeComments()
        
        // Find all declarations in the file
        findDeclarations(in: contentWithoutComments)
    }
    
    // Find all type declarations in a Swift file
    private func findDeclarations(in content: String) {
        // Find class declarations
        findComponentsOfType(ClassComponent(name: type), withKeyword: "class", in: content)
        
        // Find struct declarations
        findComponentsOfType(StructComponent(name: type), withKeyword: "struct", in: content)
        
        // Find enum declarations
        findComponentsOfType(EnumComponent(name: type), withKeyword: "enum", in: content)
        
        // Find protocol declarations
        findComponentsOfType(ProtocolComponent(name: type), withKeyword: "protocol", in: content)
        
        // Find extensions
        findExtensions(in: content)
        
        // Find typealiases
        findTypealiases(in: content)
    }
    
    // Find components of a specific type in the content
    private func findComponentsOfType(_ type: any ComponentProtocol, withKeyword keyword: String, in content: String) {
        let pattern = "(?:public|private|internal|fileprivate|open)?\\s*(?:@\\w+\\s+)*\(keyword)\\s+([A-Za-z][A-Za-z0-9_]*)(?:<[^>]*>)?\\s*(?::|\n|\\{)"
        
        guard let regex = try? NSRegularExpression(pattern: pattern) else {
            return
        }
        
        let range = NSRange(content.startIndex..<content.endIndex, in: content)
        let matches = regex.matches(in: content, range: range)
        
        for match in matches {
            if match.numberOfRanges > 1, let nameRange = Range(match.range(at: 1), in: content) {
                let componentName = String(content[nameRange])
                if componentName == type.name {
                    foundComponents[type.name] = type
                }
            }
        }
    }
    
    // Find extensions and record the types they extend
    private func findExtensions(in content: String) {
        let pattern = "extension\\s+([A-Za-z][A-Za-z0-9_]*)(?:<[^>]*>)?\\s*(?::|\\{)"
        
        guard let regex = try? NSRegularExpression(pattern: pattern) else {
            return
        }
        
        let range = NSRange(content.startIndex..<content.endIndex, in: content)
        let matches = regex.matches(in: content, range: range)
        
        for match in matches {
            if match.numberOfRanges > 1, let nameRange = Range(match.range(at: 1), in: content) {
                let componentName = String(content[nameRange])
                
                // Only record it as an extension if we haven't found the original type yet
                if foundComponents[componentName] == nil {
                    if componentName == type {
                        foundComponents[type] = ExtensionComponent(name: componentName)
                    }
                }
            }
        }
    }
    
    // Find typealiases
    private func findTypealiases(in content: String) {
        let pattern = "typealias\\s+([A-Za-z][A-ZaZ0-9_]*)(?:<[^>]*>)?\\s*="
        
        guard let regex = try? NSRegularExpression(pattern: pattern) else {
            return
        }
        
        let range = NSRange(content.startIndex..<content.endIndex, in: content)
        let matches = regex.matches(in: content, range: range)
        
        for match in matches {
            if match.numberOfRanges > 1, let nameRange = Range(match.range(at: 1), in: content) {
                let componentName = String(content[nameRange])
                if componentName == type {
                    foundComponents[type] = TypealiasComponent(name: componentName)
                }
            }
        }
    }
    
    // Analisa e extrai todas as propriedades de um componente complexo
    func extractComponentProperties(componentName: String) -> [ComponentProperty] {
        var properties: [ComponentProperty] = []
        let searchPaths = [
            "\(COMPONENTS_PATH)",
        ]
        
        Log.log("Buscando propriedades para o componente: \(componentName)")
        
        // Primeiro, identificamos arquivos que contenham a definição do componente
        var definitionFiles: [String] = []
        
        for basePath in searchPaths {
            let filePaths = scan.scanDirectory(at: basePath, type: componentName)
            
            if filePaths.isEmpty {
                Log.log("Nenhum arquivo encontrado para o componente: \(componentName) no caminho: \(basePath)", level: .warning)
                continue
            }
            
            Log.log("Arquivos encontrados para o componente: \(componentName): \(filePaths)")
            
            // Filtramos os arquivos para encontrar aqueles que contêm a definição do componente
            for filePath in filePaths {
                if let fileContent = try? String(contentsOfFile: filePath) {
                    // Verificar se o arquivo contém a definição do componente (struct ou class)
                    let componentPattern = "(class|struct)\\s+\(componentName)\\s*(?:<[^>]*>)?\\s*(?::\\s*[^{]+)?\\s*\\{"
                    if let regex = try? NSRegularExpression(pattern: componentPattern),
                       let _ = regex.firstMatch(in: fileContent, range: NSRange(location: 0, length: fileContent.count)) {
                        Log.log("Encontrada definição do componente \(componentName) em: \(filePath)")
                        definitionFiles.append(filePath)
                    }
                }
            }
        }
        
        Log.log("Arquivos com definição do componente \(componentName): \(definitionFiles.count)")
        
        // Se encontramos arquivos com a definição, processamos apenas esses arquivos
        let filesToProcess = definitionFiles.isEmpty ? [] : definitionFiles
        
        // Se não encontramos arquivos com definição, voltamos ao comportamento anterior
        if filesToProcess.isEmpty {
            Log.log("Nenhum arquivo com definição do componente encontrado. Voltando a busca normal.", level: .warning)
            
            for basePath in searchPaths {
                let filePaths = scan.scanDirectory(at: basePath, type: componentName)
                
                for filePath in filePaths {
                    if let fileContent = try? String(contentsOfFile: filePath) {
                        Log.log("Analisando arquivo: \(filePath)")
                        let extractedProperties = findProperties(in: fileContent, for: componentName)
                        if extractedProperties.isEmpty {                        Log.log("Nenhuma propriedade encontrada em: \(filePath)", level: .warning)
                    } else {
                        Log.log("Propriedades encontradas: \(extractedProperties.map { $0.name }.joined(separator: ", "))")
                    }
                    properties.append(contentsOf: extractedProperties)
                    } else {
                        Log.log("Não foi possível ler o arquivo: \(filePath)", level: .error)
                    }
                }
            }
        } else {
            // Processamos apenas os arquivos com definição do componente
            for filePath in filesToProcess {
                if let fileContent = try? String(contentsOfFile: filePath) {
                    Log.log("Analisando arquivo com definição: \(filePath)")
                    let extractedProperties = findProperties(in: fileContent, for: componentName)
                    if extractedProperties.isEmpty {
                        Log.log("Nenhuma propriedade encontrada em: \(filePath)", level: .warning)
                    } else {
                        Log.log("Propriedades encontradas: \(extractedProperties.map { $0.name }.joined(separator: ", "))")
                        
                        // Para cada propriedade complexa, processamos recursivamente
                        var enhancedProperties: [ComponentProperty] = []
                        
                        for property in extractedProperties {
                            var updatedProperty = property
                            
                            // Se a propriedade for um tipo complexo (struct ou class), buscar suas propriedades internas
                            if property.component.type == .struct || property.component.type == .class {
                                Log.log("Buscando propriedades recursivamente para \(property.name) do tipo \(property.type)")
                                let innerFinder = ComponentFinder(type: property.type)
                                let innerProperties = innerFinder.extractPropertiesFromInit(componentName: property.type)
                                
                                if !innerProperties.isEmpty {
                                    updatedProperty.innerParameters = innerProperties
                                    Log.log("Encontradas \(innerProperties.count) propriedades internas para \(property.name)")
                                }
                            }
                            
                            enhancedProperties.append(updatedProperty)
                        }
                        
                        properties.append(contentsOf: enhancedProperties)
                    }
                    
                    // Se encontramos propriedades, podemos parar a busca
                    if !properties.isEmpty {
                        break
                    }
                } else {
                    Log.log("Não foi possível ler o arquivo: \(filePath)", level: .error)
                }
            }
        }
        
        return properties
    }
    
    // Método para encontrar propriedades em um arquivo para um componente específico
    private func findProperties(in content: String, for componentName: String) -> [ComponentProperty] {
        var properties: [ComponentProperty] = []
        
        // Padrão para encontrar componentes e suas propriedades
        // Busca por class/struct NomeDoComponente [: Protocols] { ... }
        // Atualizado para lidar com conformidade a protocolos
        let componentPattern = "(class|struct)\\s+\(componentName)\\s*(?:<[^>]*>)?\\s*(?::\\s*[^{]+)?\\s*\\{((?:.|\n)*?)(?:\\n\\s*\\}|\\}\\s*$)"
        
        guard let componentRegex = try? NSRegularExpression(pattern: componentPattern) else {
            return properties
        }
        
        let contentRange = NSRange(content.startIndex..<content.endIndex, in: content)
        let componentMatches = componentRegex.matches(in: content, range: contentRange)
        
        Log.log("Analisando conteúdo para o componente: \(componentName)")
        Log.log("Número de matches do regex de componente: \(componentMatches.count)")
        
        for componentMatch in componentMatches {
            if componentMatch.numberOfRanges > 2, let bodyRange = Range(componentMatch.range(at: 2), in: content) {
                let componentBody = String(content[bodyRange])
                Log.log("Corpo do componente encontrado com \(componentBody.count) caracteres")
                
                // Padrão para encontrar propriedades dentro do corpo do componente
                // Busca por public/private/fileprivate var/let nome: Tipo [= valorPadrao]
                let propertyPattern = "(?:public|private|fileprivate|internal)?\\s*(var|let)\\s+([a-zA-Z][a-zA-Z0-9_]*)\\s*:\\s*([^=\\n{]+)(?:=\\s*([^\\n]+))?"
                
                guard let propertyRegex = try? NSRegularExpression(pattern: propertyPattern) else {
                    Log.log("Erro ao criar regex de propriedades", level: .error)
                    continue
                }
                
                let bodyContentRange = NSRange(componentBody.startIndex..<componentBody.endIndex, in: componentBody)
                let propertyMatches = propertyRegex.matches(in: componentBody, range: bodyContentRange)
                
                Log.log("Número de propriedades encontradas: \(propertyMatches.count)")
                
                for propertyMatch in propertyMatches {
                    if propertyMatch.numberOfRanges > 3, 
                       let nameRange = Range(propertyMatch.range(at: 2), in: componentBody),
                       let typeRange = Range(propertyMatch.range(at: 3), in: componentBody) {
                        
                        let propertyName = String(componentBody[nameRange])
                        var propertyType = String(componentBody[typeRange]).trimmingCharacters(in: .whitespacesAndNewlines)
                        var defaultValue: String? = nil
                        
                        Log.log("Propriedade encontrada: \(propertyName) do tipo \(propertyType)")
                        
                        // Extrai o valor padrão se existir
                        if propertyMatch.numberOfRanges > 4, let defaultValueRange = Range(propertyMatch.range(at: 4), in: componentBody) {
                            defaultValue = String(componentBody[defaultValueRange]).trimmingCharacters(in: .whitespacesAndNewlines)
                            Log.log("Valor padrão: \(defaultValue ?? "nil")")
                        }
                        
                        // Verifica se é um array, dicionário ou opcional e extrai o tipo interno
                        if propertyType.contains("[") && propertyType.contains("]") {
                            // Trata arrays e dicionários
                            propertyType = propertyType.trimmingCharacters(in: .whitespacesAndNewlines)
                        } else if propertyType.contains("?") {
                            // Trata opcionais
                            propertyType = propertyType.replacingOccurrences(of: "?", with: "").trimmingCharacters(in: .whitespacesAndNewlines)
                        }
                        
                        // Cria um ComponentFinder para determinar o tipo da propriedade
                        let propertyComponentType = ComponentFinder(type: propertyType).findComponentType()
                        
                        // Adiciona a propriedade à lista
                        let property = ComponentProperty(
                            name: propertyName,
                            type: propertyType,
                            component: propertyComponentType,
                            defaultValue: defaultValue
                        )
                        
                        properties.append(property)
                    }
                }
            }
        }
        
        return properties
    }
    
    // Método para extrair propriedades de um componente usando o InitParser
    func extractPropertiesFromInit(componentName: String) -> [ComponentProperty] {
        var properties: [ComponentProperty] = []
        let searchPaths = [
            "\(COMPONENTS_PATH)",
        ]
        
        Log.log("Buscando propriedades a partir de inicializadores para o componente: \(componentName)")
        
        // Primeiro, identificamos arquivos que contenham a definição do componente
        var definitionFiles: [String] = []
        
        for basePath in searchPaths {
            let filePaths = scan.scanDirectory(at: basePath, type: componentName)
            
            if filePaths.isEmpty {
                Log.log("Nenhum arquivo encontrado para o componente: \(componentName) no caminho: \(basePath)", level: .warning)
                continue
            }
            
            // Filtramos os arquivos para encontrar aqueles que contêm a definição do componente
            for filePath in filePaths {
                if let fileContent = try? String(contentsOfFile: filePath) {
                    // Verificar se o arquivo contém a definição do componente (struct ou class)
                    let componentPattern = "(class|struct)\\s+\(componentName)\\s*(?:<[^>]*>)?\\s*(?::\\s*[^{]+)?\\s*\\{"
                    if let regex = try? NSRegularExpression(pattern: componentPattern),
                       let _ = regex.firstMatch(in: fileContent, range: NSRange(location: 0, length: fileContent.count)) {
                        Log.log("Encontrada definição do componente \(componentName) em: \(filePath)")
                        definitionFiles.append(filePath)
                    }
                }
            }
        }
        
        Log.log("Arquivos com definição do componente \(componentName): \(definitionFiles.count)")
        
        // Se encontramos arquivos com a definição, processamos apenas esses arquivos
        let filesToProcess = definitionFiles.isEmpty ? [] : definitionFiles
        
        // Se não encontramos arquivos com definição, voltamos ao comportamento anterior
        if filesToProcess.isEmpty {
            Log.log("Nenhum arquivo com definição do componente encontrado. Voltando a busca normal.", level: .warning)
            
            for basePath in searchPaths {
                let filePaths = scan.scanDirectory(at: basePath, type: componentName)
                
                for filePath in filePaths {
                    if let fileContent = try? String(contentsOfFile: filePath) {
                        Log.log("Analisando inicializadores no arquivo: \(filePath)")
                        
                        // Usar o InitParser para extrair os inicializadores
                        let initParser = InitParser(content: fileContent, componentName: componentName)
                        let initializers = initParser.extractMultipleInits()
                        
                        if initializers.isEmpty {
                            Log.log("Nenhum inicializador encontrado em: \(filePath)", level: .warning)
                            continue
                        }
                        
                        Log.log("Inicializadores encontrados: \(initializers.count)")
                        
                        // Pegamos apenas o primeiro inicializador para extrair as propriedades
                        // Assumimos que o primeiro inicializador é representativo das propriedades da estrutura
                        if let firstInit = initializers.first {
                            for param in firstInit.parameters {
                                // Transformamos cada parâmetro em uma propriedade
                                let property = ComponentProperty(
                                    name: param.name,
                                    type: param.component.name,
                                    component: param.component,
                                    defaultValue: param.defaultValue
                                )
                                
                                // Se esta propriedade for um tipo complexo, buscar recursivamente suas propriedades
                                if param.component.type == .struct || param.component.type == .class {
                                    Log.log("Verificando propriedades internas recursivamente para \(param.name) do tipo \(param.component.name)")
                                    let innerFinder = ComponentFinder(type: param.component.name)
                                    let innerProperties = innerFinder.extractComponentProperties(componentName: param.component.name)
                                    
                                    if !innerProperties.isEmpty {
                                        var updatedProperty = property
                                        updatedProperty.innerParameters = innerProperties
                                        Log.log("Adicionando \(innerProperties.count) propriedades internas a \(param.name)")
                                        properties.append(updatedProperty)
                                    } else {
                                        Log.log("Nenhuma propriedade interna encontrada para \(param.name)")
                                        properties.append(property)
                                    }
                                } else {
                                    Log.log("Propriedade extraída de inicializador: \(property.name) do tipo \(property.type)")
                                    properties.append(property)
                                }
                            }
                        }
                        
                        // Se encontramos propriedades, podemos parar a busca
                        if !properties.isEmpty {
                            break
                        }
                    }
                }
                
                // Se encontramos propriedades, não precisamos verificar os outros caminhos
                if !properties.isEmpty {
                    break
                }
            }
        } else {
            // Processamos apenas os arquivos com definição do componente
            for filePath in filesToProcess {
                if let fileContent = try? String(contentsOfFile: filePath) {
                    Log.log("Analisando inicializadores no arquivo com definição: \(filePath)")
                    
                    // Usar o InitParser para extrair os inicializadores
                    let initParser = InitParser(content: fileContent, componentName: componentName)
                    let initializers = initParser.extractMultipleInits()
                    
                    if initializers.isEmpty {
                        Log.log("Nenhum inicializador encontrado em: \(filePath)", level: .warning)
                        continue
                    }
                    
                    Log.log("Inicializadores encontrados: \(initializers.count)")
                    
                    // Pegamos apenas o primeiro inicializador para extrair as propriedades
                    // Assumimos que o primeiro inicializador é representativo das propriedades da estrutura
                    if let firstInit = initializers.first {
                        for param in firstInit.parameters {
                            // Transformamos cada parâmetro em uma propriedade
                            let property = ComponentProperty(
                                name: param.name,
                                type: param.component.name,
                                component: param.component,
                                defaultValue: param.defaultValue
                            )
                            
                            // Se esta propriedade for um tipo complexo, buscar recursivamente suas propriedades
                            if param.component.type == .struct || param.component.type == .class {
                                Log.log("Verificando propriedades internas recursivamente para \(param.name) do tipo \(param.component.name)")
                                let innerFinder = ComponentFinder(type: param.component.name)
                                let innerProperties = innerFinder.extractComponentProperties(componentName: param.component.name)
                                
                                if !innerProperties.isEmpty {
                                    var updatedProperty = property
                                    updatedProperty.innerParameters = innerProperties
                                    Log.log("Adicionando \(innerProperties.count) propriedades internas a \(param.name)")
                                    properties.append(updatedProperty)
                                } else {
                                    Log.log("Nenhuma propriedade interna encontrada para \(param.name)")
                                    properties.append(property)
                                }
                            } else {
                                Log.log("Propriedade extraída de inicializador: \(property.name) do tipo \(property.type)")
                                properties.append(property)
                            }
                        }
                    }
                    
                    // Se encontramos propriedades, podemos parar a busca
                    if !properties.isEmpty {
                        break
                    }
                }
            }
        }
        
        return properties
    }
}
