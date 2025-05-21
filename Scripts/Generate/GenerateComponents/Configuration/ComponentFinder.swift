import Foundation

protocol ComponentProtocol: Equatable {
    var name: String { get }
    var type: ComponentType { get }
}

struct ClassComponent: ComponentProtocol {
    let name: String
    let type: ComponentType = .class
}

struct StructComponent: ComponentProtocol {
    let name: String
    let type: ComponentType = .struct
}

struct EnumComponent: ComponentProtocol {
    let name: String
    let type: ComponentType = .enum
}

struct ProtocolComponent: ComponentProtocol {
    let name: String
    let type: ComponentType = .protocol
}

struct ExtensionComponent: ComponentProtocol {
    let name: String
    let type: ComponentType = .extension
}

struct TypealiasComponent: ComponentProtocol {
    let name: String
    let type: ComponentType = .typealias
}

struct PrimitiveComponent: ComponentProtocol {
    let name: String
    let type: ComponentType = .primitive
}

struct NotFoundComponent: ComponentProtocol {
    let name: String = "notFound"
    let type: ComponentType = .notFound
}

enum ComponentType {
    case `class`
    case `struct`
    case `enum`
    case `protocol`
    case `extension`
    case `typealias`
    case primitive
    case notFound
    
    var complexType: Bool {
        self == .class || self == .struct
    }
}

class ComponentFinder {
    private let primitiveTypes: Set<String> = [
        "Int", "UInt", "Int8", "UInt8", "Int16", "UInt16", "Int32", "UInt32", "Int64", "UInt64",
        "Float", "Double", "Bool", "String", "Character",
        "Void", "Optional", "Array", "Dictionary", "Set",
        "Data", "Date", "URL"
    ]
    
    private let coreEnumTypes: Set<String> = [
        "ColorName", "FontName"
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
        var component: any ComponentProtocol = NotFoundComponent()
        for basePath in searchPaths {
            // First check if it's a primitive type
            if primitiveTypes.contains(type) {
                component = PrimitiveComponent(name: type)
            }
            
            if coreEnumTypes.contains(type) {
                component = EnumComponent(name: type)
            }
            
            // Try to find the component by scanning the directory
            scan.scanDirectory(at: basePath) { itemPath in
                // Process Swift files
                scanSwiftFile(at: itemPath)
            }
            
            // Check if we found the component
            if let componentType = foundComponents[type] {
                component = componentType
            }
            
            component = NotFoundComponent()
        }
        return component
    }
    
    // Scan a Swift file for component declarations
    private func scanSwiftFile(at path: String) {
        guard let content = try? String(contentsOfFile: path, encoding: .utf8) else {
            print("Could not read file: \(path)")
            return
        }
        
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
        let pattern = "\(keyword)\\s+([A-Za-z][A-Za-z0-9_]*)(?:<[^>]*>)?\\s*(?::|\n|\\{)"
        
        guard let regex = try? NSRegularExpression(pattern: pattern) else {
            return
        }
        
        let range = NSRange(content.startIndex..<content.endIndex, in: content)
        let matches = regex.matches(in: content, range: range)
        
        for match in matches {
            if match.numberOfRanges > 1, let nameRange = Range(match.range(at: 1), in: content) {
                let componentName = String(content[nameRange])
                foundComponents[componentName] = type
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
                    foundComponents[componentName] = ExtensionComponent(name: content)
                }
            }
        }
    }
    
    // Find typealiases
    private func findTypealiases(in content: String) {
        let pattern = "typealias\\s+([A-Za-z][A-Za-z0-9_]*)(?:<[^>]*>)?\\s*="
        
        guard let regex = try? NSRegularExpression(pattern: pattern) else {
            return
        }
        
        let range = NSRange(content.startIndex..<content.endIndex, in: content)
        let matches = regex.matches(in: content, range: range)
        
        for match in matches {
            if match.numberOfRanges > 1, let nameRange = Range(match.range(at: 1), in: content) {
                let componentName = String(content[nameRange])
                foundComponents[componentName] = TypealiasComponent(name: componentName)
            }
        }
    }
}
