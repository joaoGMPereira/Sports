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
