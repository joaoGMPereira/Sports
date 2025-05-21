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
    var type: ComponentType = .primitive
}

struct CustomComponent: ComponentProtocol {
    var name: String
    var type: ComponentType
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
    case stringImageEnum
    case primitive
    case ColorName
    case FontName
    case SFSymbol
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
}
