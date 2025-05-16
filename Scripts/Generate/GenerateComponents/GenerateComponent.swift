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
        
        // Determinar configurações específicas do componente
        let hasContentParam = ["Text", "Button", "Toggle", "TextField"].contains(componentName)
        _ = componentName == "Button" || componentInfo.hasActionParam
        _ = "\(componentName.lowercased())Style"
        _ = "\(componentName)Style"
        let styleCaseType = "\(componentName)StyleCase"
        
        // Início da estrutura
        let structStart = """
        
        struct \(sampleName): View, @preconcurrency BaseThemeDependencies {
            @Dependency(\\.themeConfigurator) var themeConfigurator
        """
        
        // Estados básicos
        var states: [String] = []
        
        // Estado para texto de exemplo se o componente precisar
        if hasContentParam {
            if componentName == "Text" {
                states.append("\n    @State private var sampleText = \"Exemplo de texto\"")
            } else if componentName == "Button" {
                states.append("\n    @State private var buttonTitle = \"Botão de Exemplo\"")
            } else if componentName == "Toggle" {
                states.append("\n    @State private var toggleLabel = \"Toggle de Exemplo\"")
                states.append("\n    @State private var isEnabled = false")
            } else if componentName == "TextField" {
                states.append("\n    @State private var textValue = \"\"")
                states.append("\n    @State private var placeholder = \"Digite aqui\"")
            }
        }
        
        // Estados para estilo
        if !componentInfo.styleCases.isEmpty {
            let defaultStyle = componentInfo.styleCases[0]
            states.append("    @State private var selectedStyle = \(styleCaseType).\(defaultStyle)")
        } else if !componentInfo.styleFunctions.isEmpty {
            let defaultStyle = componentInfo.styleFunctions[0]
            if defaultStyle.paramType == "ColorName" {
                states.append("    @State private var selectedColorName: ColorName = .contentA")
                states.append("    @State private var selectedStyleFunction = \"\(defaultStyle.name)\"")
            }
        }
        
        // Toggles para opções de visualização
        let viewOptions = """
            @State private var showAllStyles = false
            @State private var useContrastBackground = true
            @State private var showFixedHeader = false
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
        
        // ScrollView com todos os estilos
        let exampleType = styleCaseType
        var exampleCode = "// Exemplo do componente"
        
        // Preparar exemplos de código para cada componente
        let buttonExample = """
    Button(buttonTitle) {
        // Ação vazia para exemplo
    }
    .buttonStyle(style.style())
    """
        
        let textExample = """
    Text(sampleText)
        .textStyle(style.style())
    """
        
        let dividerExample = """
    Divider()
        .dividerStyle(style.style())
    """
        
        let toggleExample = """
    Toggle(toggleLabel, isOn: .constant(true))
        .toggleStyle(style.style())
    """
        
        let textFieldExample = """
    TextField(placeholder, text: .constant("Exemplo"))
        .textFieldStyle(style.style())
    """
        
        // Escolher o exemplo apropriado
        switch componentName {
        case "Button":
            exampleCode = buttonExample
        case "Text":
            exampleCode = textExample
        case "Divider":
            exampleCode = dividerExample
        case "Toggle":
            exampleCode = toggleExample
        case "TextField":
            exampleCode = textFieldExample
        default:
            break
        }
        
        let scrollView = """
            
            private var scrollViewWithStyles: some View {
                ScrollView {
                    VStack(alignment: .leading, spacing: 8) {
                        LazyVGrid(columns: [GridItem(.adaptive(minimum: 160))], spacing: 8) {
                            ForEach(\(exampleType).allCases, id: \\.self) { style in
                                VStack {
                                    Text(String(describing: style))
                                        .font(fonts.small)
                                        .foregroundColor(colors.contentA)
                                        .padding(.bottom, 2)
                                    
                                    \(exampleCode)
                                        .padding(8)
                                        .frame(maxWidth: .infinity)
                                        .background(
                                            RoundedRectangle(cornerRadius: 4)
                                                .fill(getContrastBackground(for: getColorFromStyle(style)))
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
                    // Preview do componente com as configurações atuais\n
        """
        
        // Adicionar o exemplo correto para cada tipo de componente
        switch componentName {
        case "Button":
            previewComponent += """

                        Button(buttonTitle) {
                            print("Botão pressionado")
                        }
                        .buttonStyle(selectedStyle.style())
        """
        case "Text":
            previewComponent += """

                        Text(sampleText)
                            .textStyle(selectedStyle.style())
        """
        case "Divider":
            previewComponent += """

                        Divider()
                            .dividerStyle(selectedStyle.style())
        """
        case "Toggle":
            previewComponent += """

                        Toggle(toggleLabel, isOn: $isEnabled)
                            .toggleStyle(selectedStyle.style())
        """
        case "TextField":
            previewComponent += """

                        TextField(placeholder, text: $textValue)
                            .textFieldStyle(selectedStyle.style())
        """
        default:
            previewComponent += "\n                // Preview de \(componentName)"
        }
        
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
        """
        
        switch componentName {
        case "Button":
            configurationSection += """

                    // Campo para texto do botão
                    TextField("Texto do botão", text: $buttonTitle)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .padding(.horizontal)
        """
        case "Text":
            configurationSection += """

                    // Campo para texto de exemplo
                    TextField("Texto de exemplo", text: $sampleText)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .padding(.horizontal)
        """
        case "Toggle":
            configurationSection += """

                    // Campo para label do toggle
                    TextField("Label do toggle", text: $toggleLabel)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .padding(.horizontal)
                        
                    // Toggle para testar o componente
                    Toggle("Estado do toggle", isOn: $isEnabled)
                        .toggleStyle(.default(.contentA))
                        .padding(.horizontal)
        """
        case "TextField":
            configurationSection += """

                    // Campo para valor do texto
                    TextField("Valor do texto", text: $textValue)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .padding(.horizontal)
                        
                    // Campo para placeholder
                    TextField("Placeholder", text: $placeholder)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .padding(.horizontal)
        """
        default:
            break
        }
        
        // Adicionar seletor de estilo para todos os componentes
        configurationSection += """

                    // Seletor de estilo
                    EnumSelector<\(styleCaseType)>(
                        title: "Estilo",
                        selection: $selectedStyle,
                        columnsCount: 3,
                        height: 120
                    )
                    
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
        
        // Exemplos a serem usados na função de gerar código
        let buttonCodeExample = """
    Button("\\(buttonTitle)") {
        // Ação do botão aqui
    }
    .buttonStyle(selectedStyle.style())
    """
        
        let textCodeExample = """
    Text("\\(sampleText)")
        .textStyle(selectedStyle.style())
    """
        
        let dividerCodeExample = """
    Divider()
        .dividerStyle(selectedStyle.style())
    """
        
        let toggleCodeExample = """
    Toggle("\\(toggleLabel)", isOn: $isEnabled)
        .toggleStyle(selectedStyle.style())
    """
        
        let textFieldCodeExample = """
    TextField("\\(placeholder)", text: $textValue)
        .textFieldStyle(selectedStyle.style())
    """
        
        // Geração de código Swift - corrigindo o formato da string multi-linha
        var generateCode = """
            
            // Gera o código Swift para o componente configurado
            private func generateSwiftCode() -> String {
                // Aqui você pode personalizar a geração de código com base no componente
                var code = "// Código gerado automaticamente\\n"
                
                code += \"\"\"
    """
        generateCode += "\n"
        // Código específico para cada componente
        switch componentName {
        case "Button":
            generateCode += buttonCodeExample
        case "Text":
            generateCode += textCodeExample
        case "Divider":
            generateCode += dividerCodeExample
        case "Toggle":
            generateCode += toggleCodeExample
        case "TextField":
            generateCode += textFieldCodeExample
        default:
            break
        }
        generateCode += "\n"
        generateCode += """
        \"\"\"
                
                return code
            }
        """
        
        // Helper methods padrão
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
        fullContent += helperMethods
        fullContent += "\n}"  // Fechar a struct
        
        return fullContent
    }
}
