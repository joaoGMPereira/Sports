import Foundation
// MARK: - Modelos de dados

protocol ParameterProtocol {
    var name: String { get }
    var defaultValue: String? { get }
    var component: any ComponentProtocol { get }
}

struct StyleParameter: Hashable, ParameterProtocol {
    let order: Int
    let hasObfuscatedArgument: Bool
    let isUsedAsBinding: Bool
    let name: String
    let type: String
    let component: any ComponentProtocol
    let defaultValue: String?
    
    static func == (lhs: StyleParameter, rhs: StyleParameter) -> Bool {
        // Compare all properties except 'component' which is an existential type
        return lhs.order == rhs.order &&
        lhs.hasObfuscatedArgument == rhs.hasObfuscatedArgument &&
        lhs.isUsedAsBinding == rhs.isUsedAsBinding &&
        lhs.name == rhs.name &&
        lhs.type == rhs.type &&
        lhs.defaultValue == rhs.defaultValue &&
        lhs.component.name == rhs.component.name
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(order)
        hasher.combine(hasObfuscatedArgument)
        hasher.combine(isUsedAsBinding)
        hasher.combine(name)
        hasher.combine(type)
        hasher.combine(component.name)
        hasher.combine(defaultValue)
    }
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
    var component: any ComponentProtocol
    var defaultValue: String?
    let isAction: Bool
    
    static func == (lhs: InitParameter, rhs: InitParameter) -> Bool {
        // Compare all properties except 'component' which is an existential type
        return lhs.order == rhs.order &&
        lhs.hasObfuscatedArgument == rhs.hasObfuscatedArgument &&
        lhs.isUsedAsBinding == rhs.isUsedAsBinding &&
        lhs.label == rhs.label &&
        lhs.name == rhs.name &&
        lhs.defaultValue == rhs.defaultValue &&
        lhs.isAction == rhs.isAction &&
        lhs.component.name == rhs.component.name
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(order)
        hasher.combine(hasObfuscatedArgument)
        hasher.combine(isUsedAsBinding)
        hasher.combine(label)
        hasher.combine(name)
        hasher.combine(component.name)
        hasher.combine(defaultValue)
        hasher.combine(isAction)
    }
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
            var parameterValue = switch item.component.type {
                
            case .String, .stringImageEnum:
                "\"\\(\(item.name))\""
            case .Bool:
                "\\(\(item.name))"
            case .Int, .Double, .CGFloat:
                "\(item.name)"
            default:
                if item.component.name.contains("->") {
                    "{}"
                } else {
                    if item.component.type.complexType {
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
                    if item.component.type.complexType {
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
