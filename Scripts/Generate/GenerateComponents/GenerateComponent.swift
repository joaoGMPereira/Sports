import Foundation

struct GenerateComponentConfiguration {
    var styleFunctions = Set<StyleParameter>()
    var styleParameters = Set<StyleParameter>()
    var styleParams = String()
    let initParams: [InitParameter]
    
    init(_ componentInfo: ComponentInfo) {
        var styleFunctions = Set<StyleParameter>()
        componentInfo.styleFunctions.forEach { function in
            function.parameters.forEach { parameter in
                styleFunctions.insert(parameter)
            }
        }
        var styleParameters = Set<StyleParameter>()
        componentInfo.styleParameters.forEach { function in
            function.parameters.forEach { parameter in
                styleParameters.insert(parameter)
            }
        }
        self.styleFunctions = styleFunctions
        self.styleParameters = styleParameters
        styleParams = "\(styleParameters.isEmpty ? "" : ",")"
        styleParams += Array(styleParameters).joined()
        initParams = componentInfo.publicInitParams
    }
}

final class GenerateComponent {
    let componentInfo: ComponentInfo
    let config: GenerateComponentConfiguration
    init(_ componentInfo: ComponentInfo) {
        self.componentInfo = componentInfo
        self.config = .init(componentInfo)
    }
    
    // MARK: - Geração de arquivos
    func generateNativeComponentSample() -> String {
        var fullContent = startOfFile()
        fullContent += stateVarsGenerated()
        fullContent += sampleDefaultOptions()
        fullContent += body()
        fullContent += preview()
        fullContent += configurationSection()
        fullContent += allStyles()
        fullContent += generateCode()
        fullContent += generateGetStyle()
        fullContent += generateEnumStyle()
        
        return fullContent
    }
    
    func startOfFile() -> String {
        let componentName = componentInfo.name
        let sampleName = "\(componentName)Sample"
        // Importações básicas
        let imports = """
        import SwiftUI
        import Zenith
        import ZenithCoreInterface
        import SFSafeSymbols
        """
        
        // Início da estrutura
        let structStart = """
        
        struct \(sampleName): View, @preconcurrency BaseThemeDependencies {
            @Dependency(\\.themeConfigurator) var themeConfigurator
        """
        
        var content = imports
        content += structStart
        return content
    }
    
    func stateVarsGenerated() -> String {
        // Estados básicos padronizados
        var states: [String] = []
        
        if componentInfo.hasDefaultSampleText {
            // Estado para texto de exemplo padronizado para todos os componentes
            states.append("\n    @State private var sampleText = \"Exemplo de texto\"")
        }
        
        // Estados específicos para tipo de componente
        states.append("\n    @State private var style: Generate\(componentInfo.name)SampleEnum = .\(componentInfo.styleFunctions.first!.name)")
        
        states.append(contentsOf: stateVars(Array(config.styleFunctions)))
        states.append(contentsOf: stateVars(Array(config.styleParameters)))
        states.append(contentsOf: stateVars(config.initParams))
        
        return "\(states.joined(separator: "\n"))\n"
    }
    
    func stateVars(_ parameters: [ParameterProtocol]) -> [String] {
        var states: [String] = []
        parameters.forEach { parameter in
            if let defaultValue = parameter.defaultValue {
                if parameter.type == "String" && (defaultValue.isEmpty || defaultValue == "\"\"") {
                    states.append("\n    @State private var \(parameter.name): \(parameter.type) = \"Sample text\"")
                } else {
                    if parameter.type == "StringImageEnum" {
                        states.append(
                            """
                            @State private var \(parameter.name): String = \"figure.run\"
                            @State private var symbolSearch = ""
                            var filteredSymbols: [String] {
                                if symbolSearch.isEmpty {
                                    return SFSymbol.allSymbols.map{ $0.rawValue }.sorted()
                                }
                                return SFSymbol.allSymbols
                                    .filter { $0.rawValue.lowercased().contains(symbolSearch.lowercased()) }
                                    .map { $0.rawValue }
                                    .prefix(100)
                                    .sorted()
                            }
                            """
                        )
                    } else {
                        states.append("\n    @State private var \(parameter.name): \(parameter.type) = \(defaultValue)")
                    }
                }
            } else {
                states.append(defaultUnsetVar(parameter))
            }
        }
        return states
    }
    
    func defaultUnsetVar(_ parameter: ParameterProtocol) -> String {
        let firstStyle = componentInfo.styleFunctions.first!
        var defaultParameters = ""
        defaultParameters += firstStyle.parameters.joined()
        let defaultCase = ".\(firstStyle.name)(\(defaultParameters))"
        
        return switch parameter.type {
        case "String":
            "\n    @State private var \(parameter.name): \(parameter.type) = \"Sample text\""
        case "StringImageEnum":
            """
            @State private var \(parameter.name): String = \"figure.run\"
            @State private var symbolSearch = ""
            var filteredSymbols: [String] {
                if symbolSearch.isEmpty {
                    return SFSymbol.allSymbols.map{ $0.rawValue }.sorted()
                }
                return SFSymbol.allSymbols
                    .filter { $0.rawValue.lowercased().contains(symbolSearch.lowercased()) }
                    .map { $0.rawValue }
                    .prefix(100)
                    .sorted()
            }
            """
        case "Bool":
            "\n    @State private var \(parameter.name): \(parameter.type) = false"
        case "Int", "Double", "CGFloat":
            "\n    @State private var \(parameter.name): \(parameter.type) = 1"
        default:
            if parameter.type.contains("->") || parameter.type.contains("escaping") {
                "\n    @State private var \(parameter.name): \(parameter.type) = {}"
            } else {
                "\n    @State private var \(parameter.name): \(parameter.type) = \(defaultCase)"
            }
        }
    }
    
    func sampleDefaultOptions() -> String {
        // Toggles para opções de visualização´
        return """
        
            @State private var showAllStyles = false
            @State private var useContrastBackground = true
            @State private var showFixedHeader = false\n
        """
    }
    
    func body() -> String {
        """
            
            var body: some View {
                SampleWithFixedHeader(
                    showFixedHeader: $showFixedHeader,
                    content: {
                        Card(action: {
                            showFixedHeader.toggle()
                        }) {
                            VStack(spacing: 16) {
                                // Preview do componente com configurações atuais
                                previewComponent
                            }
                            .padding()
                        }
                        .padding()
                    },
                    config: {
                        VStack(spacing: 16) {
                            // Área de configuração
                            configurationSection
                            
                            // Preview do código gerado
                            CodePreviewSection(generateCode: generateSwiftCode)
                            
                            // Exibição de todos os estilos (opcional)
                            if showAllStyles {
                                Divider().padding(.vertical, 4)
                                
                                VStack(alignment: .leading, spacing: 12) {
                                    Text("Todos os Estilos")
                                        .font(fonts.mediumBold)
                                        .foregroundColor(colors.contentA)
                                    
                                    allStyles
                                }
                            }
                        }
                        .padding(.horizontal)
                    }
                )
            }
        """
    }
    
    func preview() -> String {
        var previewComponent = """
            
            // Preview do componente com as configurações selecionadas
            private var previewComponent: some View {
                VStack {
                    // Preview do componente com as configurações atuais
        """
        
        previewComponent += """
        
                \(componentInfo.exampleCode)
                .\(componentInfo.name.firstLowerCased)Style(get\(componentInfo.name)Style(style.rawValue)\(config.styleParams))
        """
        previewComponent += """
                    \n .padding()
                    .frame(maxWidth: .infinity)
                    .background(
                        RoundedRectangle(cornerRadius: 8)
                            .fill(useContrastBackground ? colors.backgroundA : colors.backgroundB.opacity(0.2))
                    )
                }
            }
        """
        return previewComponent
    }
    
    func configurationSection() -> String {
        var sampleText = ""
        if componentInfo.hasDefaultSampleText {
            sampleText = """
            // Campo para texto de exemplo
            TextField("", text: $sampleText)
                .textFieldStyle(.contentA(), placeholder: "Texto de exemplo")
                .padding(.horizontal)
            """
        }
        var configurationSection = """
            
            // Área de configuração
            private var configurationSection: some View {
                VStack(spacing: 16) {
                    \(sampleText)
                    EnumSelector<Generate\(componentInfo.name)SampleEnum>(
                        title: "\(componentInfo.name) Estilos",
                        selection: $style,
                        columnsCount: 3,
                        height: 120
                    )
                    .padding(.horizontal)\n
        """

        configurationSection += interactiveComponents(Array(config.styleFunctions))
        configurationSection += interactiveComponents(Array(config.styleParameters))
        configurationSection += interactiveComponents(config.initParams)
        
        // Adicionar toggles para opções de visualização para todos os componentes
        configurationSection += """
                    // Toggles para opções
                    VStack {
                        Toggle("Usar fundo contrastante", isOn: $useContrastBackground)
                            .toggleStyle(.default(.highlightA))
                        
                        Toggle("Mostrar Todos os Estilos", isOn: $showAllStyles)
                            .toggleStyle(.default(.highlightA))
                    }
                    .padding(.horizontal)
                }
            }
        """
        return configurationSection
    }
    
    func interactiveComponents(_ parameters: [ParameterProtocol]) -> String {
        var interactiveComponents = ""
        parameters.forEach { parameter in
            let parameterComponent = switch parameter.type {
            case "String":
                """
                TextField("", text: $\(parameter.name))
                    .textFieldStyle(.contentA(), placeholder: "\(parameter.name)")
                    .padding(.horizontal)\n
                """
            case "StringImageEnum":
                """
                Text("Ícone")
                    .font(fonts.smallBold)
                    .foregroundColor(colors.contentA)
                
                TextField("Buscar símbolo", text: $symbolSearch)
                    .textFieldStyle(.roundedBorder)
                
                ScrollView {
                    LazyVGrid(columns: [GridItem(.adaptive(minimum: 80))], spacing: 8) {
                        ForEach(filteredSymbols, id: \\.self) { symbol in
                            VStack {
                                Image(systemName: symbol)
                                    .font(.system(size: 22))
                                    .frame(width: 44, height: 44)
                                    .background(
                                        Circle()
                                            .fill(symbol == \(parameter.name) ?
                                                  colors.highlightA : colors.backgroundB)
                                    )
                                    .foregroundColor(symbol == \(parameter.name) ?
                                                     colors.contentC : colors.contentA)
                                
                                Text(symbol)
                                    .font(fonts.small)
                                    .foregroundColor(colors.contentA)
                                    .lineLimit(1)
                                    .truncationMode(.tail)
                            }
                            .frame(width: 80, height: 80)
                            .contentShape(Rectangle())
                            .onTapGesture {
                                \(parameter.name) = symbol
                            }
                        }
                    }
                }
                .frame(height: 200)
                .background(colors.backgroundB.opacity(0.5))
                .cornerRadius(8)
                """
            case "Bool":
                """
                Toggle("\(parameter.name)", isOn: $\(parameter.name))
                    .toggleStyle(.default(.highlightA))
                    .padding(.horizontal)\n
                """
            case "Int", "Double", "CGFloat":
                """
                Slider(value: $\(parameter.name), in: 0...100, step: 1)
                    .accentColor(colors.highlightA)
                    .padding(.horizontal)\n
                """
            default:
                if parameter.type.contains("->") {
                    ""
                } else {
                    """
                    EnumSelector<\(parameter.type)>(
                        title: "\(parameter.type)",
                        selection: $\(parameter.name),
                        columnsCount: 3,
                        height: 120
                    )
                    .padding(.horizontal)\n
                    """
                }
            }
            interactiveComponents += parameterComponent
        }
        return interactiveComponents
    }
    
    func allStyles() -> String {
        var allStyles = "\n\n"
        allStyles += """
            private var allStyles: some View {
                ScrollView {
                    VStack(alignment: .leading, spacing: 8) {
                        // Mostrar todas as funções de estilo disponíveis
                        LazyVGrid(columns: [GridItem(.adaptive(minimum: 160))], spacing: 8) {
                            ForEach(\(componentInfo.name)StyleCase.allCases, id: \\.self) { style in
                                VStack {
                                    \(componentInfo.exampleCode)
                                    .\(componentInfo.name.firstLowerCased)Style(style.style()\(config.styleParams))
                                    .padding(8)
                                    .frame(maxWidth: .infinity)
                                    .background(
                                        RoundedRectangle(cornerRadius: 4)
                                            .fill(colors.backgroundB.opacity(0.2))
                                    )
                                }
                            }
                        }
                    }
                }
                .frame(maxHeight: 200)
            }
            """
        return allStyles
    }
    
    func generateCode() -> String {
        var generateCode = """
            
            // Gera o código Swift para o componente configurado
            private func generateSwiftCode() -> String {
                var code = "// Código gerado automaticamente\\n"
                
        """
        var styleFunctionsCases: [String] = []
        componentInfo.styleFunctions.forEach { styleFunction in
            var parameters = ""
            parameters += styleFunction.parameters.sampleJoined()
            styleFunctionsCases.append("\".\(styleFunction.name)(\(parameters))\"")
        }
        
        var styleParametersCases: String = ""
        componentInfo.styleParameters.forEach { styleParameter in
            var parameters = styleParameter.parameters.isEmpty ? "" : ", "
            parameters += styleParameter.parameters.sampleJoined()
            styleParametersCases.append(parameters)
        }
        
        generateCode += """
        let styleFunctionsCases = [\(styleFunctionsCases.joined(separator: ", "))]
        let selectedStyle = styleFunctionsCases.first(where: { $0.contains(style.rawValue) }) ?? \".\\(style.rawValue)()\"
        code += \"\"\"
        \(componentInfo.generateCode)
        .\(componentInfo.name.firstLowerCased)Style(\\(selectedStyle)\(styleParametersCases))
        \"\"\"\n
        """
        generateCode += """
                return code
            }
        """
        
        return generateCode
    }
    
    func generateGetStyle() -> String {
        let name = componentInfo.name
        var cases = ""
        componentInfo.styleFunctions.forEach { styleFunction in
            var parameters = ""
            parameters += styleFunction.parameters.joined()
            cases += "case \"\(styleFunction.name)\":\n"
            cases += "    .\(styleFunction.name)(\(parameters))\n"
        }
        
        let firstStyle = componentInfo.styleFunctions.first!
        var defaultParameters = ""
        defaultParameters += firstStyle.parameters.joined()
        let prefix = componentInfo.contextualModule ? "Zenith." : ""
        let defaultCase = """
            default:
                .\(firstStyle.name)(\(defaultParameters))
        """
        return """
        
            private func get\(name)Style(_ style: String) -> Any\(name)Style {
                let style: any \(prefix)\(componentInfo.name)Style = switch style {
                \(cases)
                \(defaultCase)
                }
                return Any\(name)Style(style)
            }
        \n}
        """
    }
    
    func generateEnumStyle() -> String {
        var cases = ""
        componentInfo.styleFunctions.forEach { styleFunction in
            var parameters = ""
            parameters += styleFunction.parameters.joined()
            var name = styleFunction.name
            if styleFunction.name == "default" {
                name = "`\(name)`"
            }
            cases += "case \(name)\n"
        }
        
        return """
        
            enum Generate\(componentInfo.name)SampleEnum: String, CaseIterable, Identifiable {
                public var id: Self { self }
        
                \(cases)
            }
        """
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
                    ".\\(\(item.name).rawValue)"
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
