import Foundation

// Estrutura para armazenar informações de um inicializador
struct InitializerInfo {
    let index: Int
    var name: String // Nome descritivo para o inicializador
    let parameters: [InitParameter]
    
    // Propriedade para verificar se este inicializador usa uma configuração
    var usesConfiguration: Bool {
        return parameters.contains { param in
            param.component.name.contains("StyleConfiguration") || param.name == "configuration"
        }
    }
    
    init(index: Int, parameters: [InitParameter]) {
        self.index = index
        self.parameters = parameters
        self.name = "padrao"
        // Gerar um nome descritivo para o inicializador baseado nos parâmetros
        if usesConfiguration {
            self.name = "config"
        } else if parameters.isEmpty {
            self.name = "padrao"
        } else {
            // Para evitar nomes duplicados, incluir o índice no nome do inicializador
            let significantParams = parameters.prefix(2).map { $0.name }.joined(separator: "_")
            self.name = significantParams.isEmpty ? "init\(index)" : "\(significantParams)_\(index)"
        }
    }
}

extension InitParser {
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
    
    // Método para agrupar os parâmetros em inicializadores
    func extractMultipleInits() -> [InitializerInfo] {
        var allInitializers: [InitializerInfo] = []
        
        // Padrão para localizar inicializadores públicos, incluindo os genéricos
        // (?:<[^>]*>)? captura o parâmetro genérico opcional como <T: View>
        let initPattern = "public\\s+init(?:<[^>]*>)?\\s*\\(([^\\{]*)\\)"
        let initRegex = try! NSRegularExpression(pattern: initPattern, options: [.dotMatchesLineSeparators])
        let initMatches = initRegex.matches(in: content, options: [], range: NSRange(content.startIndex..., in: content))
        
        for (index, match) in initMatches.enumerated() {
            guard let paramsRange = Range(match.range(at: 1), in: content) else {
                continue
            }
            
            let paramsStr = String(content[paramsRange]).trimmingCharacters(in: .whitespaces)
            if paramsStr.isEmpty {
                continue
            }
            
            if index == 9 {
                print("aqui")
            }
            
            // Extrair os parâmetros usando uma função melhorada para lidar com closures
            let params = extractBalancedParameters(from: paramsStr)
            
            // Log de debug para verificar os parâmetros extraídos
            Log.log("Inicializador \(index): \(params)", level: .info)
            
            var initParams: [InitParameter] = []
            
            // Processar cada parâmetro individualmente
            for (paramIndex, paramString) in params.enumerated() {
                let param = paramString.replacingOccurrences(of: "\n", with: " ").trimmingCharacters(in: .whitespaces)
                
                // Nova abordagem: análise baseada em tokens em vez de regex
                if var initParam = parseInitParameter(param, index: paramIndex) {
                    fillInnerParameters(parameter: &initParam)
                    initParams.append(initParam)
                    Log.log("Parâmetro processado com sucesso: \(initParam.name): \(initParam.component.name)", level: .info)
                }
            }
            
            // Filtrar parâmetros duplicados
            var filteredInitParams: [InitParameter] = []
            
            initParams.forEach { param in
                // Tratamento especial para Imagem em String (SFSymbol)
                if filteredInitParams.contains(where: { $0.name == param.name && $0.component.type == .String && param.component.name == "SFSymbol" }), var foundInitParam = filteredInitParams.first(where: { $0.name == param.name && $0.component.type == .String }) {
                    filteredInitParams.removeAll(where: { $0.name == param.name && $0.component.type == .String })
                    foundInitParam.defaultValue = "\"figure.run\""
                    foundInitParam.component.name = "StringImageEnum"
                    foundInitParam.component.type = .String
                    filteredInitParams.append(foundInitParam)
                }
                if filteredInitParams.contains(where: { $0.name == param.name }) == false && param.component.name.contains("StyleConfiguration") == false {
                    filteredInitParams.append(param)
                }
            }
            
            // Adicionar o inicializador à lista
            if !filteredInitParams.isEmpty {
                let initializerInfo = InitializerInfo(index: index, parameters: filteredInitParams)
                allInitializers.append(initializerInfo)
            }
        }
        
        return allInitializers
    }
}
