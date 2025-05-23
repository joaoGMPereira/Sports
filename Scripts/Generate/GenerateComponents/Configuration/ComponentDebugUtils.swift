import Foundation

// Extensão para ComponentInfo para depuração das propriedades recursivas
extension ComponentInfo {
    
    // Método para imprimir toda a estrutura de propriedades do componente
    func printFullStructure() {
        print("\n=== ESTRUTURA COMPLETA DO COMPONENTE \(name) ===")
        print("Tipo: \(isNative ? "Nativo" : "Customizado")")
        print("Caminho da View: \(viewPath)")
        print("Caminho dos Estilos: \(stylesPath)")
        
        print("\n=== PARÂMETROS DE INICIALIZAÇÃO (\(publicInitParams.count)) ===")
        for (index, param) in publicInitParams.enumerated() {
            print("\n[\(index + 1)] \(param.name): \(param.component.name)")
            
            if param.component.type == .struct || param.component.type == .class {
                print("  Tipo: COMPLEXO (\(param.component.type.rawValue))")
                
                if param.innerParameters.isEmpty {
                    print("  Sem propriedades internas mapeadas")
                } else {
                    print("  Propriedades internas:")
                    for innerParam in param.innerParameters {
                        print("  \(innerParam.prettyDescription(level: 1))")
                    }
                }
            } else {
                print("  Tipo: \(param.component.type.rawValue)")
            }
        }
        
        if !styleParameters.isEmpty {
            print("\n=== PARÂMETROS DE ESTILO (\(styleParameters.count)) ===")
            for (styleIndex, styleParam) in styleParameters.enumerated() {
                print("\n[\(styleIndex + 1)] Função de estilo: \(styleParam.name)")
                
                for (paramIndex, param) in styleParam.parameters.enumerated() {
                    print("  [\(paramIndex + 1)] \(param.name): \(param.component.name)")
                    
                    if param.component.type == .struct || param.component.type == .class {
                        print("    Tipo: COMPLEXO (\(param.component.type.rawValue))")
                        
                        if param.innerParameters.isEmpty {
                            print("    Sem propriedades internas mapeadas")
                        } else {
                            print("    Propriedades internas:")
                            for innerParam in param.innerParameters {
                                print("    \(innerParam.prettyDescription(level: 2))")
                            }
                        }
                    } else {
                        print("    Tipo: \(param.component.type.rawValue)")
                    }
                }
            }
        }
        
        print("\n=== CÓDIGO DE EXEMPLO GERADO ===")
        print(generateCode)
        print("\n================================\n")
    }
}

// Função para imprimir a estrutura de um componente para depuração
func printComponentStructure(componentName: String) {
    let config = ComponentConfiguration()
    if let componentInfo = config.findComponentFiles(componentName) {
        componentInfo.printFullStructure()
    } else {
        print("Componente '\(componentName)' não encontrado!")
    }
}
