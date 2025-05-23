import Foundation

// Extensão para preencher propriedades internas (innerParameters) em componentes complexos
extension ComponentConfiguration {
    
    // Método para preencher innerParameters para um parâmetro complexo
    func fillInnerParameters(parameter: inout InitParameter) {
        // Verificar se o componente é complexo (struct ou class)
        if parameter.component.type == .struct || parameter.component.type == .class {
            Log.log("Preenchendo innerParameters para \(parameter.name) do tipo \(parameter.component.name)")
            
            // Usar o ComponentFinder para extrair as propriedades do componente
            let finder = ComponentFinder(type: parameter.component.name)
            
            // Utilizamos a nova implementação do extractPropertiesFromInit que primeiro
            // busca arquivos com a definição do componente
            let properties = finder.extractPropertiesFromInit(componentName: parameter.component.name)
            
            // Atribuir as propriedades encontradas ao innerParameters do parâmetro
            parameter.innerParameters = properties
            
            if !properties.isEmpty {
                Log.log("Propriedades internas encontradas: \(properties.map { $0.name }.joined(separator: ", "))")
            } else {
                Log.log("Nenhuma propriedade interna encontrada para \(parameter.component.name)")
            }
        }
    }
    
    // Método para preencher innerParameters para um parâmetro de estilo complexo
    func fillStyleParameters(parameter: inout StyleParameter) {
        // Verificar se o componente é complexo (struct ou class)
        if parameter.component.type == .struct || parameter.component.type == .class {
            Log.log("Preenchendo innerParameters para o parâmetro de estilo \(parameter.name) do tipo \(parameter.component.name)")
            
            // Usar o ComponentFinder para extrair as propriedades do componente
            let finder = ComponentFinder(type: parameter.component.name)
            let properties = finder.extractPropertiesFromInit(componentName: parameter.component.name)
            
            // Atribuir as propriedades encontradas ao innerParameters do parâmetro
            parameter.innerParameters = properties
            
            if !properties.isEmpty {
                Log.log("Propriedades internas de estilo encontradas: \(properties.map { $0.name }.joined(separator: ", "))")
            } else {
                Log.log("Nenhuma propriedade interna encontrada para o parâmetro de estilo \(parameter.component.name)")
            }
        }
    }
    
    // Método para preencher as propriedades internas de todos os parâmetros de um componente
    func fillAllInnerParameters(componentInfo: inout ComponentInfo) {
        // Preencher para parâmetros de inicialização
        for i in 0..<componentInfo.publicInitParams.count {
            fillInnerParameters(parameter: &componentInfo.publicInitParams[i])
        }
        
        // Preencher para parâmetros de estilo
        for i in 0..<componentInfo.styleParameters.count {
            for j in 0..<componentInfo.styleParameters[i].parameters.count {
                fillStyleParameters(parameter: &componentInfo.styleParameters[i].parameters[j])
            }
        }
    }
}
