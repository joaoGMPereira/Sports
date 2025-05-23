import Foundation

// Extensão para imprimir estrutura de propriedades de forma recursiva
extension ComponentProperty {
    
    // Retorna uma representação indentada da propriedade e suas propriedades internas
    func prettyDescription(level: Int = 0) -> String {
        let indent = String(repeating: "  ", count: level)
        var result = "\(indent)- \(name): \(type)"
        
        if let defaultValue = defaultValue {
            result += " = \(defaultValue)"
        }
        
        if innerParameters.isEmpty {
            return result
        }
        
        result += " {\n"
        
        for innerProperty in innerParameters {
            result += "\(innerProperty.prettyDescription(level: level + 1))\n"
        }
        
        result += "\(indent)}"
        
        return result
    }
    
    // Retorna uma representação simples para logs
    var simpleDescription: String {
        var result = "\(name): \(type)"
        
        if !innerParameters.isEmpty {
            result += " (contém \(innerParameters.count) propriedades internas)"
        }
        
        return result
    }
    
    // Gera código de exemplo para esta propriedade
    func generateSampleCode() -> String {
        if innerParameters.isEmpty {
            // Para propriedades simples
            switch component.type {
            case .String:
                return "\"exemplo\""
            case .Int, .UInt, .Int8, .UInt8, .Int16, .UInt16, .Int32, .UInt32, .Int64, .UInt64:
                return "0"
            case .Float, .Double, .CGFloat:
                return "0.0"
            case .Bool:
                return "false"
            case .enum:
                return ".\(type.lowercased())Valor"
            default:
                if type.contains("[") {
                    return "[]"
                } else if type.contains("?") {
                    return "nil"
                } else {
                    return "\(type)()"
                }
            }
        } else {
            // Para propriedades complexas
            var code = "\(type)(\n"
            
            for (index, property) in innerParameters.enumerated() {
                code += "    \(property.name): \(property.generateSampleCode())"
                
                if index < innerParameters.count - 1 {
                    code += ","
                }
                
                code += "\n"
            }
            
            code += ")"
            return code
        }
    }
}
