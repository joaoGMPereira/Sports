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
        let hasActionParam = componentName == "Button" || componentInfo.hasActionParam
        let styleCaseType = "\(componentName)StyleCase"
        
        // Início da estrutura
        let structStart = """
        
        struct \(sampleName): View, @preconcurrency BaseThemeDependencies {
            @Dependency(\\.themeConfigurator) var themeConfigurator
        """
        
        // Estados básicos padronizados
        var states: [String] = []
        
        // Estado para texto de exemplo padronizado para todos os componentes
        states.append("\n    @State private var sampleText = \"Exemplo de texto\"")
        
        // Estado para cor padronizado para todos os componentes
        states.append("\n    @State private var selectedColor: ColorName = .highlightA")
        
        // Estados específicos para tipo de componente
        if componentName == "Text" {
            states.append("\n    @State private var selectedStyleFunction = \"medium\"")
        } else if componentName != "Divider" {
            states.append("\n    @State private var selectedStyle = \(styleCaseType).\(componentInfo.styleCases.first ?? "contentA")")
        }
        
        if componentName == "Toggle" {
            states.append("\n    @State private var isEnabled = false")
        } else if componentName == "TextField" {
            states.append("\n    @State private var showError = false")
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
        
        // ScrollView com todos os estilos baseado no tipo de componente
        var scrollView = ""
        
        if componentName == "Text" {
            scrollView = """
            
            private var scrollViewWithStyles: some View {
                ScrollView {
                    VStack(alignment: .leading, spacing: 16) {
                        ForEach(StyleFunctionName.allCases, id: \\.self) { function in
                            VStack(alignment: .leading, spacing: 8) {
                                Text(function.rawValue)
                                    .font(fonts.smallBold)
                                    .foregroundColor(colors.contentA)
                                    .padding(.bottom, 4)
                                
                                LazyVGrid(columns: [GridItem(.adaptive(minimum: 160))], spacing: 8) {
                                    ForEach(ColorName.allCases, id: \\.self) { color in
                                        VStack {
                                            Text(color.rawValue)
                                                .font(fonts.small)
                                                .foregroundColor(colors.contentA)
                                                .padding(.bottom, 2)
                                            
                                            Text(sampleText)
                                                .textStyle(getTextStyle(function: function.rawValue, color: color))
                                                .padding(8)
                                                .frame(maxWidth: .infinity)
                                                .background(
                                                    RoundedRectangle(cornerRadius: 4)
                                                        .fill(getContrastBackground(for: color))
                                                )
                                        }
                                    }
                                }
                            }
                            .padding(.vertical, 8)
                        }
                    }
                }
                .frame(maxHeight: 200)
            }
            """
        } else {
            // Para Button, Divider, Toggle, TextField e outros componentes
            let exampleType = styleCaseType
            var exampleCode = ""
            
            // Preparar exemplos de código específicos para cada componente
            switch componentName {
            case "Button":
                exampleCode = """
        Button(sampleText) {
            // Ação vazia para exemplo
        }
        .buttonStyle(style.style())
        """
            case "Divider":
                exampleCode = """
        Divider()
        .dividerStyle(style.style())
        """
            case "Toggle":
                exampleCode = """
        Toggle(sampleText, isOn: .constant(true))
        .toggleStyle(style.style())
        """
            case "TextField":
                exampleCode = """
        TextField(sampleText, text: .constant(""))
        .textFieldStyle(style.style())
        """
            default:
                exampleCode = "// Exemplo para \(componentName)"
            }
            
            scrollView = """
            
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
        }
        
        // Criando a seção de preview do componente
        var previewComponent = """
            
            // Preview do componente com as configurações selecionadas
            private var previewComponent: some View {
                VStack {
                    // Preview do componente com as configurações atuais
        """
        
        // Adicionar o exemplo correto para cada tipo de componente
        switch componentName {
        case "Button":
            previewComponent += """

                    Button(sampleText) {
                        print("Botão pressionado")
                    }
                    .buttonStyle(selectedStyle.style())
            """
        case "Text":
            previewComponent += """

                    Text(sampleText)
                        .textStyle(getTextStyle(function: selectedStyleFunction, color: selectedColor))
            """
        case "Divider":
            previewComponent += """

                    Divider()
                        .dividerStyle(.contentA())
            """
        case "Toggle":
            previewComponent += """

                    Toggle(sampleText, isOn: $isEnabled)
                        .toggleStyle(.default(selectedColor))
            """
        case "TextField":
            previewComponent += """

                    TextField(sampleText, text: .constant(""))
                        .textFieldStyle(selectedStyle.style(), 
                          hasError: showError, 
                          errorMessage: showError ? .constant("Campo com erro") : .constant(""))
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
                    // Campo para texto de exemplo
                    TextField("Texto de exemplo", text: $sampleText)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .padding(.horizontal)
        """
        
        // Adicionar configurações específicas para cada componente
        switch componentName {
        case "Text":
            configurationSection += """

                    // Seletor para função de estilo
                    EnumSelector<StyleFunctionName>(
                        title: "Estilo",
                        selection: Binding(
                            get: { StyleFunctionName(rawValue: selectedStyleFunction) ?? .medium },
                            set: { selectedStyleFunction = $0.rawValue }
                        ),
                        columnsCount: 3,
                        height: 120
                    )
            """
        case "TextField":
            configurationSection += """
                    
                    // Toggle para mostrar erro
                    Toggle("Mostrar erro", isOn: $showError)
                        .toggleStyle(.default(.highlightA))
                        .padding(.horizontal)
                    
                    // Seletor de estilo
                    EnumSelector<TextFieldStyleCase>(
                        title: "Estilo",
                        selection: $selectedStyle,
                        columnsCount: 3,
                        height: 120
                    )
            """
        case "Toggle":
            configurationSection += """
                    
                    // Toggle para testar o componente
                    Toggle("Estado do toggle", isOn: $isEnabled)
                        .toggleStyle(.default(.contentA))
                        .padding(.horizontal)
            """
        case "Button":
            configurationSection += """
                    
                    // Seletor de estilo
                    EnumSelector<ButtonStyleCase>(
                        title: "Estilo",
                        selection: $selectedStyle,
                        columnsCount: 3,
                        height: 120
                    )
            """
        case "Divider":
            configurationSection += """
                    // Este componente não tem configurações específicas além da cor
            """
        default:
            break
        }
        
        // Adicionar seletor de cor para todos os componentes (exceto quando já tiver configurações específicas)
        if componentName != "Text" {
            configurationSection += """
                    
                    // Seletor para cor
                    EnumSelector<ColorName>(
                        title: "Cor",
                        selection: $selectedColor,
                        columnsCount: 3,
                        height: 120
                    )
            """
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
        
        // Código específico para cada componente
        switch componentName {
        case "Button":
            generateCode += """
                code += \"\"\"
        Button("\\(sampleText)") {
            // Ação do botão aqui
        }
        .buttonStyle(selectedStyle.style())
        \"\"\"
        """
        case "Text":
            generateCode += """
                code += \"\"\"
        Text("\\(sampleText)")
            .textStyle(.\\(selectedStyleFunction)(.\\(String(describing: selectedColor))))
        \"\"\"
        """
        case "Divider":
            generateCode += """
                code += \"\"\"
        Divider()
            .dividerStyle(.contentA())
        \"\"\"
        """
        case "Toggle":
            generateCode += """
                code += \"\"\"
        Toggle("\\(sampleText)", isOn: $isEnabled)
            .toggleStyle(.default(.\\(String(describing: selectedColor))))
        \"\"\"
        """
        case "TextField":
            generateCode += """
                code += \"\"\"
        TextField("\\(sampleText)", text: $textValue)
            .textFieldStyle(selectedStyle.style()\\(showError ? ", hasError: true" : ""))
        \"\"\"
        """
        default:
            generateCode += """
                code += \"\"\"
        // Código para \(componentName)
        \"\"\"
        """
        }
        
        generateCode += """
                
                return code
            }
        """
        
        // Função helper para os estilos do Text
        var textStyleHelper = ""
        if componentName == "Text" {
            textStyleHelper = """
            
            // Helper para obter o estilo correspondente à função selecionada
            private func getTextStyle(function: String, color: ColorName) -> some TextStyle {
                switch function {
                case "small":
                    return .small(color)
                case "smallBold":
                    return .smallBold(color)
                case "medium":
                    return .medium(color)
                case "mediumBold":
                    return .mediumBold(color)
                case "large":
                    return .large(color)
                case "largeBold":
                    return .largeBold(color)
                case "bigBold":
                    return .bigBold(color)
                default:
                    return .small(color)
                }
            }
            """
        }
        
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
        
        // Adicionar enum para as funções de estilo do Text
        var styleEnums = ""
        if componentName == "Text" {
            styleEnums = """
            
            // Enum para seleção das funções de estilo
            fileprivate enum StyleFunctionName: String, CaseIterable, Identifiable {
                case small = "small", smallBold = "smallBold", medium = "medium", mediumBold = "mediumBold", large = "large", largeBold = "largeBold", bigBold = "bigBold"
                
                var id: Self { self }
            }
            """
        }
        
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
        fullContent += textStyleHelper
        fullContent += helperMethods
        fullContent += styleEnums
        fullContent += "\n}"  // Fechar a struct
        
        return fullContent
    }
}
