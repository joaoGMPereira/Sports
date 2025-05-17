import Foundation

final class GenerateComponent {
    
    // MARK: - Geração de arquivos
    
    func generateNativeComponentSample(_ componentInfo: ComponentInfo) -> String {
        let componentName = componentInfo.name
        let sampleName = "\(componentName)Sample"
        
        // Importações básicas
        let imports = """
        import SwiftUI
        import Zenith
        import ZenithCoreInterface
        """
        
        // Início da estrutura
        let structStart = """
        
        struct \(sampleName): View, @preconcurrency BaseThemeDependencies {
            @Dependency(\\.themeConfigurator) var themeConfigurator
        """
        
        // Estados básicos padronizados
        var states: [String] = []
        
        // Estado para texto de exemplo padronizado para todos os componentes
        states.append("\n    @State private var sampleText = \"Exemplo de texto\"")
        
        // Estados específicos para tipo de componente
        states.append("\n    @State private var style = \"\(componentInfo.styleFunctions.first!.name)\"")
        
        var uniqueParameters = Set<StyleParameter>()
        componentInfo.styleFunctions.forEach { function in
            function.parameters.forEach { parameter in
                uniqueParameters.insert(parameter)
            }
        }
        uniqueParameters.forEach { parameter in
            if let defaultValue = parameter.defaultValue {
                states.append("\n    @State private var \(parameter.name): \(parameter.type) = \(defaultValue)")
            } else {
                states.append("\n    @State private var \(parameter.name): (\(parameter.type))?")
            }
        }
        
        let uniqueInitParams = componentInfo.publicInitParams

        uniqueInitParams.forEach { initParam in
            if let defaultValue = initParam.defaultValue {
                states.append("\n    @State private var \(initParam.name): \(initParam.type) = \(defaultValue)")
            } else {
                states.append("\n    @State private var \(initParam.name): (\(initParam.type))?")
            }
        }
        
        // Toggles para opções de visualização´
        let viewOptions = """
            @State private var showAllStyles = false
            @State private var useContrastBackground = true
            @State private var showFixedHeader = false\n
        """
        
        // Implementação do body com preview e configuração
        let bodyContent = """
            
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
                                    
                                    scrollViewWithStyles
                                }
                            }
                        }
                        .padding(.horizontal)
                    }
                )
            }
        """
        
        // ScrollView com todos os estilos baseado no tipo de componente
        var scrollView = "\n\n"
        scrollView += """
            private var scrollViewWithStyles: some View {
                ScrollView {
                    VStack(alignment: .leading, spacing: 8) {
                        // Mostrar todas as funções de estilo disponíveis
                        LazyVGrid(columns: [GridItem(.adaptive(minimum: 160))], spacing: 8) {
                            ForEach(\(componentInfo.name)StyleCase.allCases, id: \\.self) { style in
                                VStack {
                                    \(componentInfo.exampleCode)
                                    .\(componentInfo.name.firstLowerCased)Style(style.style())
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
        
        // Criando a seção de preview do componente
        var previewComponent = """
            
            // Preview do componente com as configurações selecionadas
            private var previewComponent: some View {
                VStack {
                    // Preview do componente com as configurações atuais
        """
        
        previewComponent += """
        
                \(componentInfo.exampleCode)
                .\(componentInfo.name.firstLowerCased)Style(get\(componentInfo.name)Style(style))
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
        
        // Configuração específica para cada componente
        var configurationSection = """
            
            // Área de configuração
            private var configurationSection: some View {
                VStack(spacing: 16) {
                    // Campo para texto de exemplo
                    TextField("Texto de exemplo", text: $sampleText)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .padding(.horizontal)\n
        """
        
        uniqueParameters.forEach { parameter in
            let parameterComponent = switch parameter.type {
            case "String":
                """
                TextField("\(parameter.name)", text: $\(parameter.name))
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding(.horizontal)\n
                """
            case "Bool":
                """
                Toggle("\(parameter.name)", isOn: $\(parameter.name))
                    .toggleStyle(.default(.highlightA))\n
                """
            case "Int", "Double", "CGFloat":
                """
                Slider(value: $\(parameter.name), in: 0...100, step: 1)
                    .accentColor(colors.highlightA)\n
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
                    )\n
                    """
                }
            }
            configurationSection += parameterComponent
        }
        
        uniqueInitParams.forEach { parameter in
            let parameterComponent = switch parameter.type {
            case "String":
                """
                TextField("\(parameter.name)", text: $\(parameter.name))
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding(.horizontal)\n
                """
            case "Bool":
                """
                Toggle("\(parameter.name)", isOn: $\(parameter.name))
                    .toggleStyle(.default(.highlightA))\n
                """
            case "Int", "Double", "CGFloat":
                """
                Slider(value: $\(parameter.name), in: 0...100, step: 1)
                    .accentColor(colors.highlightA)\n
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
                    )\n
                    """
                }
            }
            configurationSection += parameterComponent
        }
        
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
        
        // Geração de código Swift com base no componente
        var generateCode = """
            
            // Gera o código Swift para o componente configurado
            private func generateSwiftCode() -> String {
                var code = "// Código gerado automaticamente\\n"
                
        """
        generateCode += """
        code += \"\"\"
        \(componentInfo.exampleCode)
        .\(componentInfo.name.firstLowerCased)Style(.\\(style)())
        \"\"\"\n
        """
        generateCode += """
                return code
            }
        """
        
        // Substituir helpers específicos por um helper genérico
        let styleHelpers = """
        
            \(generateGetStyle(with: componentInfo))
        """
        
        // Combinar tudo
        var fullContent = imports
        fullContent += structStart
        fullContent += states.joined(separator: "\n")
        fullContent += "\n" + viewOptions
        fullContent += bodyContent
        fullContent += scrollView
        fullContent += previewComponent
        fullContent += configurationSection
        fullContent += generateCode
        fullContent += styleHelpers
        
        // Adicionar o helperMethods que estava faltando
        let helperMethods = """
            
            // Helper para obter a cor associada a um StyleCase
            private func getColorFromStyle<T>(_ style: T) -> ColorName {
                let styleName = String(describing: style)
                
                if styleName.contains("HighlightA") {
                    return .highlightA
                } else if styleName.contains("BackgroundA") {
                    return .backgroundA
                } else if styleName.contains("BackgroundB") {
                    return .backgroundB
                } else if styleName.contains("BackgroundC") {
                    return .backgroundC
                } else if styleName.contains("BackgroundD") {
                    return .backgroundD
                } else if styleName.contains("ContentA") {
                    return .contentA
                } else if styleName.contains("ContentB") {
                    return .contentB
                } else if styleName.contains("ContentC") {
                    return .contentC
                } else if styleName.contains("Critical") {
                    return .critical
                } else if styleName.contains("Attention") {
                    return .attention
                } else if styleName.contains("Danger") {
                    return .danger
                } else if styleName.contains("Positive") {
                    return .positive
                } else {
                    return .none
                }
            }
            
            // Gera um fundo de contraste adequado para a cor especificada
            private func getContrastBackground(for colorName: ColorName) -> Color {
                let color = colors.color(by: colorName) ?? colors.backgroundB
                
                // Extrair componentes RGB da cor
                let uiColor = UIColor(color)
                var red: CGFloat = 0
                var green: CGFloat = 0
                var blue: CGFloat = 0
                var alpha: CGFloat = 0
                
                uiColor.getRed(&red, green: &green, blue: &blue, alpha: &alpha)
                
                // Calcular luminosidade da cor (fórmula perceptual)
                let luminance = 0.299 * red + 0.587 * green + 0.114 * blue
                
                // Verificar se estamos lidando com a cor backgroundC ou cores com luminosidade similar
                if (abs(luminance - 0.27) < 0.1) { // 0.27 é aproximadamente a luminosidade de #444444
                    // Para cinzas médios como backgroundC, criar um contraste mais definido
                    if luminance < 0.3 {
                        // Para cinzas que tendem ao escuro, usar um contraste bem claro
                        return Color.white.opacity(0.25)
                    } else {
                        // Para cinzas que tendem ao claro, usar um contraste bem escuro
                        return Color.black.opacity(0.15)
                    }
                }
                
                // Para as demais cores, manter a lógica anterior mas aumentar o contraste
                if luminance < 0.5 {
                    // Para cores escuras, gerar um contraste claro
                    return Color(red: min(red + 0.4, 1.0), 
                                green: min(green + 0.4, 1.0), 
                                blue: min(blue + 0.4, 1.0))
                        .opacity(0.35)
                } else {
                    // Para cores claras, gerar um contraste escuro
                    return Color(red: max(red - 0.25, 0.0), 
                                green: max(green - 0.25, 0.0), 
                                blue: max(blue - 0.25, 0.0))
                        .opacity(0.2)
                }
            }
        """
        
        fullContent += helperMethods
        fullContent += "\n}"  // Fechar a struct
        
        return fullContent
    }
    
    func generateGetStyle(with componentInfo: ComponentInfo) -> String {
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
        enumerated().map { index, item in
            var parameterString = "\(item.name): \(item.name)"
            if item.hasObfuscatedArgument {
                parameterString = item.name
            }
            return index < count - 1 ? "\(parameterString)," : parameterString
        }.joined(separator: " ")
    }
}
