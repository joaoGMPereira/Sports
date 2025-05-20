import Foundation

enum ComponentType {
    case `class`
    case `struct`
    case `enum`
    case `protocol`
    case `extension`
    case `typealias`
    case primitive
    case notFound
    
    var description: String {
        switch self {
        case .class: return "Class"
        case .struct: return "Struct"
        case .enum: return "Enum"
        case .protocol: return "Protocol"
        case .extension: return "Extension"
        case .typealias: return "Typealias"
        case .primitive: return "Primitive Type"
        case .notFound: return "Not Found"
        }
    }
    
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
    private var foundComponents: [String: ComponentType] = [:]
    
    // Find component type by name by scanning a directory recursively
    func findComponentType(named componentName: String) -> ComponentType {
        let searchPaths = [
            "\(COMPONENTS_PATH)",

        ]
        var type: ComponentType = .primitive
        for basePath in searchPaths {
            // First check if it's a primitive type
            if primitiveTypes.contains(componentName) {
                type = .primitive
            }
            
            if coreEnumTypes.contains(componentName) {
                type = .enum
            }
            
            // Try to find the component by scanning the directory
            scanDirectory(at: basePath)
            
            // Check if we found the component
            if let componentType = foundComponents[componentName] {
                type = componentType
            }
            
            type = .notFound
        }
        return type
    }
    
    // Recursively scan a directory for Swift files
    private func scanDirectory(at path: String) {
        let fileManager = FileManager.default
        
        guard let contents = try? fileManager.contentsOfDirectory(atPath: path) else {
            print("Could not access directory: \(path)")
            return
        }
        
        for item in contents {
            let itemPath = (path as NSString).appendingPathComponent(item)
            var isDirectory: ObjCBool = false
            
            guard fileManager.fileExists(atPath: itemPath, isDirectory: &isDirectory) else {
                continue
            }
            
            if isDirectory.boolValue {
                // Recursively scan subdirectories
                scanDirectory(at: itemPath)
            } else if itemPath.hasSuffix(".swift") {
                // Process Swift files
                scanSwiftFile(at: itemPath)
            }
        }
    }
    
    // Scan a Swift file for component declarations
    private func scanSwiftFile(at path: String) {
        guard let content = try? String(contentsOfFile: path, encoding: .utf8) else {
            print("Could not read file: \(path)")
            return
        }
        
        // Remove comments to avoid false positives
        let contentWithoutComments = removeComments(from: content)
        
        // Find all declarations in the file
        findDeclarations(in: contentWithoutComments)
    }
    
    // Remove comments from Swift code to avoid false positives
    private func removeComments(from content: String) -> String {
        var result = content
        
        // Remove block comments (/* ... */)
        while let range = result.range(of: "/\\*[\\s\\S]*?\\*/", options: .regularExpression) {
            result.removeSubrange(range)
        }
        
        // Remove line comments (// ...)
        let lines = result.components(separatedBy: .newlines)
        let processedLines = lines.map { line -> String in
            if let range = line.range(of: "//.*$", options: .regularExpression) {
                return String(line[..<range.lowerBound])
            }
            return line
        }
        
        return processedLines.joined(separator: "\n")
    }
    
    // Find all type declarations in a Swift file
    private func findDeclarations(in content: String) {
        // Find class declarations
        findComponentsOfType(.class, withKeyword: "class", in: content)
        
        // Find struct declarations
        findComponentsOfType(.struct, withKeyword: "struct", in: content)
        
        // Find enum declarations
        findComponentsOfType(.enum, withKeyword: "enum", in: content)
        
        // Find protocol declarations
        findComponentsOfType(.protocol, withKeyword: "protocol", in: content)
        
        // Find extensions
        findExtensions(in: content)
        
        // Find typealiases
        findTypealiases(in: content)
    }
    
    // Find components of a specific type in the content
    private func findComponentsOfType(_ type: ComponentType, withKeyword keyword: String, in content: String) {
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
                    foundComponents[componentName] = .extension
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
                foundComponents[componentName] = .typealias
            }
        }
    }
}
