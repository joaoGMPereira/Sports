import Foundation
// MARK: - Modelos de dados

protocol ParameterProtocol {
    var name: String { get }
    var type: String { get }
    var defaultValue: String? { get }
    var componentType: ComponentType { get }
}

struct StyleParameter: Hashable, ParameterProtocol {
    let order: Int
    let hasObfuscatedArgument: Bool
    let isUsedAsBinding: Bool
    let name: String
    let type: String
    let componentType: ComponentType
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
    let componentType: ComponentType
    var defaultValue: String?
    let isAction: Bool
}

class ComponentInfo {
    let name: String
    let typePath: String
    
    var viewPath: String = ""
    var stylesPath: String = ""
    
    var hasDefaultSampleText = true
    
    var styleCases: [String] = []
    var styleParameters: [StyleConfig] = []
    var styleFunctions: [StyleConfig] = []
    
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
                    if item.componentType.complexType {
                        ""
                    } else {
                        ".\\(\(item.name).rawValue)"
                    }
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

extension String {
    var capitalizedSentence: String {
        // 1
        let firstLetter = self.prefix(1).capitalized
        // 2
        let remainingLetters = self.dropFirst().lowercased()
        // 3
        return firstLetter + remainingLetters
    }
    
    var firstLowerCased: String {
        // 1
        let firstLetter = self.prefix(1).lowercased()
        // 2
        let remainingLetters = self.dropFirst()
        // 3
        return firstLetter + remainingLetters
    }
}

extension Array where Element == StyleParameter {
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
                
            case "String":
                "\"\\(\(item.name))\""
            case "Bool":
                "\\(\(item.name))"
            case "Int", "Double", "CGFloat":
                "\(item.name)"
            default:
                if item.type.contains("->") {
                    "{}"
                } else {
                    if item.componentType.complexType {
                        "\(item.name)()"
                    } else {
                        ".\\(\(item.name).rawValue)"
                    }
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
