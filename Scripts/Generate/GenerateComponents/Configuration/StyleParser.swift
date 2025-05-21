import Foundation

struct StyleParser {
    let content: String
    let componentName: String
    
    init(content: String, componentName: String) {
        self.content = content
        self.componentName = componentName
    }
    
    func extractStyleCases() -> [String] {
        var cases = Set<String>() // Uso Set para evitar duplicatas
        
        // Procura por enum com nome que termina com StyleCase
        let enumPattern = "enum\\s+(\\w+StyleCase)[^{]*\\{"
        let enumRegex = try! NSRegularExpression(pattern: enumPattern, options: [])
        
        // Tentar encontrar a declaração do enum
        let enumMatches = enumRegex.matches(in: content, options: [], range: NSRange(content.startIndex..., in: content))
        
        for enumMatch in enumMatches {
            guard let enumStartRange = Range(enumMatch.range, in: content) else {
                continue
            }
            
            // Encontrar o fim do bloco do enum contando chaves
            let blockStart = content.index(after: content.index(enumStartRange.upperBound, offsetBy: -1))
            var braceCount = 1
            var blockEnd = blockStart
            
            while braceCount > 0 && blockEnd < content.endIndex {
                let char = content[blockEnd]
                if char == "{" {
                    braceCount += 1
                } else if char == "}" {
                    braceCount -= 1
                }
                
                if braceCount > 0 {
                    blockEnd = content.index(after: blockEnd)
                }
            }
            
            // Extrai todo o conteúdo do enum, mas paramos antes de qualquer função dentro do enum
            let fullBlockContent = String(content[blockStart..<blockEnd])
            
            // Remover qualquer parte que comece com "func", que seria uma função dentro do enum
            var blockContent = fullBlockContent
            if let funcRange = fullBlockContent.range(of: "\\s+func\\s+", options: .regularExpression) {
                blockContent = String(fullBlockContent[fullBlockContent.startIndex..<funcRange.lowerBound])
            }
            
            // Padrão 1: case a, b, c, d (em uma única linha)
            let multiCasePattern = "case\\s+([^:\\{\\n]+)"
            let multiCaseRegex = try! NSRegularExpression(pattern: multiCasePattern, options: [])
            let multiCaseMatches = multiCaseRegex.matches(in: blockContent, options: [], range: NSRange(blockContent.startIndex..., in: blockContent))
            
            for match in multiCaseMatches {
                guard let caseListRange = Range(match.range(at: 1), in: blockContent) else {
                    continue
                }
                
                let caseList = String(blockContent[caseListRange])
                    .trimmingCharacters(in: .whitespacesAndNewlines)
                
                // Separar casos múltiplos listados na mesma linha (a, b, c)
                let caseNames = caseList.components(separatedBy: ",")
                    .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
                    .filter { !$0.isEmpty && !$0.hasPrefix(".") } // Filtra valores vazios e que começam com ponto
                
                cases.formUnion(caseNames)
            }
            
            // Para casos que estão em linhas separadas, usamos um padrão diferente
            let singleCasePattern = "case\\s+(\\w+)\\s*$"
            let singleCaseRegex = try! NSRegularExpression(pattern: singleCasePattern, options: [.anchorsMatchLines])
            let singleCaseMatches = singleCaseRegex.matches(in: blockContent, options: [], range: NSRange(blockContent.startIndex..., in: blockContent))
            
            for match in singleCaseMatches {
                guard let caseRange = Range(match.range(at: 1), in: blockContent) else {
                    continue
                }
                
                let caseName = String(blockContent[caseRange])
                    .trimmingCharacters(in: .whitespacesAndNewlines)
                
                // Verificar se o caso não está vazio e não começa com ponto
                if !caseName.isEmpty && !caseName.hasPrefix(".") {
                    cases.insert(caseName)
                }
            }
        }
        
        // Se não encontrou casos suficientes, tenta uma abordagem alternativa
        // Procuramos apenas por 'case' seguido de palavra, mas não dentro de uma função
        if cases.count < 2 {
            // Encontrar primeiro todas as funções para excluí-las da busca
            var functionsRanges: [Range<String.Index>] = []
            let funcPattern = "func\\s+\\w+\\s*\\([^)]*\\)\\s*[^{]*\\{"
            let funcRegex = try! NSRegularExpression(pattern: funcPattern, options: [.dotMatchesLineSeparators])
            let funcMatches = funcRegex.matches(in: content, options: [], range: NSRange(content.startIndex..., in: content))
            
            for match in funcMatches {
                guard let matchRange = Range(match.range, in: content) else { continue }
                
                // Encontrar o fim do bloco da função
                var braceCount = 1
                var endIndex = content.index(after: matchRange.upperBound)
                
                while braceCount > 0 && endIndex < content.endIndex {
                    if content[endIndex] == "{" {
                        braceCount += 1
                    } else if content[endIndex] == "}" {
                        braceCount -= 1
                    }
                    
                    if braceCount > 0 {
                        endIndex = content.index(after: endIndex)
                    }
                }
                
                functionsRanges.append(matchRange.lowerBound..<endIndex)
            }
            
            // Agora vamos procurar todos os 'case' que não estejam dentro de funções
            let directCasePattern = "case\\s+(\\w+)(?:\\s*,\\s*(\\w+))*"
            let directCaseRegex = try! NSRegularExpression(pattern: directCasePattern, options: [])
            let directCaseMatches = directCaseRegex.matches(in: content, options: [], range: NSRange(content.startIndex..., in: content))
            
            matchLoop: for match in directCaseMatches {
                guard let matchRange = Range(match.range, in: content) else { continue }
                
                // Verificar se o match está dentro de alguma função
                for funcRange in functionsRanges {
                    if funcRange.contains(matchRange.lowerBound) {
                        continue matchLoop
                    }
                }
                
                // Extrair cada grupo de captura
                for i in 1..<match.numberOfRanges {
                    guard let caseRange = Range(match.range(at: i), in: content),
                            match.range(at: i).location != NSNotFound else { continue }
                    
                    let caseName = String(content[caseRange])
                        .trimmingCharacters(in: .whitespacesAndNewlines)
                    
                    if !caseName.isEmpty && !caseName.hasPrefix(".") {
                        cases.insert(caseName)
                    }
                }
            }
        }
        
        // Log para debug
        Log.log("Casos de estilo extraídos: \(Array(cases).sorted())", level: .info)
        
        return Array(cases).sorted()
    }
    
    func extractStyleFunctions() -> [StyleConfig] {
        var styleFunctions: [StyleConfig] = []
        var uniqueFunctionNames = Set<String>() // Para evitar duplicações
        
        // Log para debug
        Log.log("Extraindo funções de estilo para \(componentName)", level: .info)
        
        // Padrão simplificado para localizar extensões de estilo do componente
        // Captura qualquer extensão pública que se refira ao estilo do componente
        let extensionPatterns = [
            // Extensões específicas para o componente
            "public\\s+extension\\s+\(componentName)Style"
        ]
        
        // Encontra todas as extensões no conteúdo
        var extensionRanges: [(ClosedRange<String.Index>, String)] = []
        
        for pattern in extensionPatterns {
            let regex = try! NSRegularExpression(pattern: pattern, options: [])
            let matches = regex.matches(in: content, options: [], range: NSRange(content.startIndex..., in: content))
            
            for match in matches {
                guard let extensionRange = Range(match.range, in: content) else { continue }
                
                // Encontrar o bloco de código da extensão
                guard let openBraceIndex = content[extensionRange.upperBound...].firstIndex(of: "{") else { continue }
                
                var braceCount = 1
                var closeIndex = content.index(after: openBraceIndex)
                
                while braceCount > 0 && closeIndex < content.endIndex {
                    let char = content[closeIndex]
                    if char == "{" {
                        braceCount += 1
                    } else if char == "}" {
                        braceCount -= 1
                    }
                    if braceCount > 0 {
                        closeIndex = content.index(after: closeIndex)
                    }
                }
                
                if braceCount == 0 {
                    let blockRange = content[openBraceIndex...closeIndex]
                    extensionRanges.append((openBraceIndex...closeIndex, String(blockRange)))
                }
            }
        }
        
        // Extrai as funções de cada bloco de extensão
        for (_, extensionContent) in extensionRanges {
            let functions = extractFunctionsFromBlock(extensionContent)
            for function in functions {
                if !uniqueFunctionNames.contains(function.name) {
                    uniqueFunctionNames.insert(function.name)
                    styleFunctions.append(function)
                }
            }
        }
        
        // Além disso, procurar diretamente por static func que retornam Self
        // Isso captura funções que possam estar em outras extensões
        let directFunctions = extractAllStaticFunctionsFromContent(content)
        
        // Adicionar funções encontradas diretamente, se ainda não foram adicionadas
        for function in directFunctions {
            if !uniqueFunctionNames.contains(function.name) {
                uniqueFunctionNames.insert(function.name)
                styleFunctions.append(function)
                Log.log("Função de estilo encontrada diretamente: \(function.name)", level: .info)
            }
        }
        
        // Log para debug
        Log.log("Funções de estilo encontradas: \(styleFunctions.map { $0.name }.joined(separator: ", "))", level: .info)
        
        return styleFunctions.isEmpty ? extractGenericStyleFunctions() : styleFunctions
    }
    
    func extractStyleParameters() -> [StyleConfig] {
        var styleConfigs: [StyleConfig] = []
        
        // Log para debug
        Log.log("Extraindo parâmetros de estilo para \(componentName)", level: .info)
        
        // Padrão para localizar extensões que contenham funções de estilo do componente
        let extensionPattern = "public\\s+extension\\s+([^{]*)\\s*\\{[^}]*func\\s+(\\w+)Style\\s*\\(([^\\)]*)\\)"
        let extensionRegex = try! NSRegularExpression(pattern: extensionPattern, options: [.dotMatchesLineSeparators])
        let extensionMatches = extensionRegex.matches(in: content, options: [], range: NSRange(content.startIndex..., in: content))
        
        for match in extensionMatches {
            if match.numberOfRanges < 4 {
                continue
            }
            
            guard let extensionTypeRange = Range(match.range(at: 1), in: content),
                  let functionNameRange = Range(match.range(at: 2), in: content),
                  let paramsRange = Range(match.range(at: 3), in: content) else {
                continue
            }
            
            let extensionType = String(content[extensionTypeRange]).trimmingCharacters(in: .whitespaces)
            let functionName = String(content[functionNameRange]).trimmingCharacters(in: .whitespaces)
            
            // Verificamos se a extensão ou a função corresponde ao componente desejado
            // A função pode ser componenteStyle (ex: textFieldStyle) ou apenas style
            let matchesComponent = extensionType.contains(componentName) ||
            functionName.lowercased() == componentName.lowercased()
            
            if !matchesComponent {
                continue
            }
            
            // Extrair todos os parâmetros da função de estilo
            let paramsString = String(content[paramsRange]).trimmingCharacters(in: .whitespaces)
            var parameters: [StyleParameter] = []
            
            // Precisamos lidar com o primeiro parâmetro de forma especial, pois é o estilo
            let paramsList = splitFunctionParameters(paramsString)
            
            // Ignorar o primeiro parâmetro se for o estilo
            let startIndex = paramsList.isEmpty ? 0 : (paramsList[0].contains("style") || paramsList[0].contains("_ style") ? 1 : 0)
            
            for i in startIndex..<paramsList.count {
                if let styleParam = parseParameter(paramsList[i], index: i) {
                    parameters.append(styleParam)
                }
            }
            
            // Nome do estilo baseado no componente
            let styleConfigName = "default"
            styleConfigs.append(StyleConfig(name: styleConfigName, parameters: parameters))
            
            Log.log("Função de estilo encontrada para \(componentName): \(styleConfigName) com \(parameters.count) parâmetros", level: .info)
            for param in parameters {
                Log.log("- Parâmetro: \(param.name) do tipo \(param.type) \(param.defaultValue != nil ? "com valor padrão: \(param.defaultValue!)" : "")", level: .info)
            }
        }
        
        // Caso não encontre nenhuma configuração de estilo, retorna uma lista vazia
        return styleConfigs
    }
}

fileprivate extension StyleParser {
    func extractGenericStyleFunctions() -> [StyleConfig] {
        var styleFunctions: [StyleConfig] = []
        
        // Procura por padrões como: static func contentA() -> Self { .init() }
        // ou static func small(_ color: ColorName) -> Self { ... }
        // Usamos um padrão mais robusto que consegue lidar com parênteses aninhados nos valores padrão
        let genericFunctionPattern = "static\\s+func\\s+(\\w+)\\s*\\((.*?)\\)\\s*->\\s*Self"
        let functionRegex = try! NSRegularExpression(pattern: genericFunctionPattern, options: [.dotMatchesLineSeparators])
        let functionMatches = functionRegex.matches(in: content, options: [], range: NSRange(content.startIndex..., in: content))
        
        for match in functionMatches {
            guard let nameRange = Range(match.range(at: 1), in: content) else { continue }
            let funcName = String(content[nameRange])
            
            var parameters: [StyleParameter] = []
            
            // Extrair os parâmetros
            if match.numberOfRanges > 2, let paramsRange = Range(match.range(at: 2), in: content) {
                let paramsString = String(content[paramsRange]).trimmingCharacters(in: .whitespaces)
                
                if !paramsString.isEmpty {
                    let paramsList = splitFunctionParameters(paramsString)
                    
                    for (index, param) in paramsList.enumerated() {
                        if let styleParam = parseParameter(param, index: index) {
                            parameters.append(styleParam)
                        }
                    }
                }
            }
            
            styleFunctions.append(StyleConfig(name: funcName, parameters: parameters))
        }
        
        return styleFunctions
    }
    
    // Função melhorada para extrair todas as funções static -> Self do conteúdo
    func extractAllStaticFunctionsFromContent(_ content: String) -> [StyleConfig] {
        var styleFunctions: [StyleConfig] = []
        var uniqueFunctionNames = Set<String>()
        
        // Padrão universal para funções estáticas que retornam Self
        // Captura qualquer função estática independente de qual extensão ela está
        // Usamos um padrão mais robusto que consegue lidar com parênteses aninhados nos valores padrão
        let staticFuncPattern = "static\\s+func\\s+(\\w+)\\s*\\((.*?)\\)\\s*->\\s*Self"
        let funcRegex = try! NSRegularExpression(pattern: staticFuncPattern, options: [.dotMatchesLineSeparators])
        let funcMatches = funcRegex.matches(in: content, options: [], range: NSRange(content.startIndex..., in: content))
        
        for match in funcMatches {
            guard let nameRange = Range(match.range(at: 1), in: content) else { continue }
            let funcName = String(content[nameRange])
            
            if !uniqueFunctionNames.contains(funcName) {
                uniqueFunctionNames.insert(funcName)
                
                // Extrair parâmetros
                var parameters: [StyleParameter] = []
                if match.numberOfRanges > 2, let paramsRange = Range(match.range(at: 2), in: content) {
                    let paramsString = String(content[paramsRange]).trimmingCharacters(in: .whitespaces)
                    
                    if !paramsString.isEmpty {
                        let paramsList = splitFunctionParameters(paramsString)
                        
                        for (index, param) in paramsList.enumerated() {
                            if let styleParam = parseParameter(param, index: index) {
                                parameters.append(styleParam)
                            }
                        }
                    }
                }
                
                styleFunctions.append(StyleConfig(name: funcName, parameters: parameters))
            }
        }
        
        return styleFunctions
    }
    
    func extractFunctionsFromBlock(_ content: String) -> [StyleConfig] {
        var functions: [StyleConfig] = []
        let content = content.replacingOccurrences(of: "`", with: "")
        
        // Padrão para encontrar funções estáticas que retornam Self
        // Usamos um padrão mais robusto que consegue lidar com parênteses aninhados nos valores padrão
        let functionPattern = "static\\s+func\\s+(\\w+)\\s*\\((.*?)\\)\\s*->\\s*Self"
        let functionRegex = try! NSRegularExpression(pattern: functionPattern, options: [.dotMatchesLineSeparators])
        let functionMatches = functionRegex.matches(in: content, options: [], range: NSRange(content.startIndex..., in: content))
        
        for match in functionMatches {
            guard let nameRange = Range(match.range(at: 1), in: content) else { continue }
            let funcName = String(content[nameRange])
            
            var parameters: [StyleParameter] = []
            
            // Extrair os parâmetros
            if match.numberOfRanges > 2, let paramsRange = Range(match.range(at: 2), in: content) {
                let paramsString = String(content[paramsRange]).trimmingCharacters(in: .whitespaces)
                
                if !paramsString.isEmpty {
                    let paramsList = splitFunctionParameters(paramsString)
                    
                    for (index, param) in paramsList.enumerated() {
                        if let styleParam = parseParameter(param, index: index) {
                            parameters.append(styleParam)
                        }
                    }
                }
            }
            
            functions.append(StyleConfig(name: funcName, parameters: parameters))
        }
        
        return functions
    }
    
    func splitFunctionParameters(_ paramsString: String) -> [String] {
        var params: [String] = []
        var currentParam = ""
        var braceCount = 0
        var inQuotes = false
        
        for char in paramsString {
            switch char {
            case "," where braceCount == 0 && !inQuotes:
                params.append(currentParam.trimmingCharacters(in: .whitespaces))
                currentParam = ""
            case "(", "[", "{":
                braceCount += 1
                currentParam.append(char)
            case ")", "]", "}":
                braceCount -= 1
                currentParam.append(char)
            case "\"":
                inQuotes.toggle()
                currentParam.append(char)
            default:
                currentParam.append(char)
            }
        }
        
        if !currentParam.trimmingCharacters(in: .whitespaces).isEmpty {
            params.append(currentParam.trimmingCharacters(in: .whitespaces))
        }
        
        return params
    }
    
    func parseParameter(_ paramString: String, index: Int) -> StyleParameter? {
        // Padrão para extrair nome e tipo do parâmetro + valor padrão opcional
        let paramPattern = "(?:_\\s+)?(\\w+)\\s*:\\s*([^=]+)(?:\\s*=\\s*(.+))?"
        let paramRegex = try! NSRegularExpression(pattern: paramPattern, options: [])
        
        guard let match = paramRegex.firstMatch(in: paramString, options: [], range: NSRange(paramString.startIndex..., in: paramString)) else {
            return nil
        }
        
        guard let nameRange = Range(match.range(at: 1), in: paramString),
              let typeRange = Range(match.range(at: 2), in: paramString) else {
            return nil
        }
        
        let name = String(paramString[nameRange])
        var type = String(paramString[typeRange]).trimmingCharacters(in: .whitespaces)
        
        var defaultValue: String? = nil
        if match.numberOfRanges > 3, let defaultValueRange = Range(match.range(at: 3), in: paramString) {
            defaultValue = String(paramString[defaultValueRange]).trimmingCharacters(in: .whitespaces)
        }
        
        var isUsedAsBinding = false
        
        if type.contains("Binding") {
            type = type.replacingOccurrences(of: "Binding<", with: "").replacingOccurrences(of: ">", with: "")
            isUsedAsBinding = true
        }
        
        if defaultValue?.contains(".constant") == true {
            defaultValue = defaultValue?.replacingOccurrences(of: ".constant(", with: "").replacingOccurrences(of: ")", with: "")
        }
        return StyleParameter(
            order: index,
            hasObfuscatedArgument: paramString.starts(with: "_"),
            isUsedAsBinding: isUsedAsBinding,
            name: name,
            type: type,
            component: ComponentFinder(type: type).findComponentType(),
            defaultValue: defaultValue
        )
    }
}
