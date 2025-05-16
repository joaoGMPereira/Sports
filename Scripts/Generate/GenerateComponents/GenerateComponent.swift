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
        
        // Estado para cor padronizado para todos os componentes
        states.append("\n    @State private var selectedColor: ColorName = .highlightA")
        
        // Estados específicos para tipo de componente
        states.append("\n    @State private var selectedStyleFunction = \"\(componentInfo.styleFunctions.first!.name)\"")
        
        // Adicionar estados para parâmetros adicionais comuns
        if componentName == "Button" {
            states.append("\n    @State private var selectedShape = \"rounded\"")
            states.append("\n    @State private var selectedState = \"enabled\"")
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
            scrollView = """
            
            private var scrollViewWithStyles: some View {
                ScrollView {
                    VStack(alignment: .leading, spacing: 8) {
                        // Mostrar todas as funções de estilo disponíveis
                        LazyVGrid(columns: [GridItem(.adaptive(minimum: 160))], spacing: 8) {
                            ForEach(componentInfo.styleFunctions, id: \\.name) { styleFunc in
                                VStack {
                                    Text(styleFunc.name)
                                        .font(fonts.small)
                                        .foregroundColor(colors.contentA)
                                        .padding(.bottom, 2)
                                    
                                    Group {
                                        if componentName == "Button" {
                                            Button(sampleText) {
                                                // Ação vazia
                                            }
                                            .buttonStyle(applyDynamicStyle(for: componentName, function: styleFunc.name, color: .highlightA))
                                        } else if componentName == "Divider" {
                                            Divider()
                                                .dividerStyle(applyDynamicStyle(for: componentName, function: styleFunc.name, color: .highlightA))
                                        } else if componentName == "Toggle" {
                                            Toggle(sampleText, isOn: .constant(true))
                                                .toggleStyle(applyDynamicStyle(for: componentName, function: styleFunc.name, color: .highlightA))
                                        } else if componentName == "TextField" {
                                            TextField(sampleText, text: .constant(""))
                                                .textFieldStyle(applyDynamicStyle(for: componentName, function: styleFunc.name, color: .highlightA))
                                        } else {
                                            // Componentes personalizados
                                            Text("\\(styleFunc.name)")
                                                .font(fonts.small)
                                                .padding(4)
                                                .foregroundColor(colors.highlightA)
                                                .frame(height: 40)
                                        }
                                    }
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
                    .buttonStyle(applyDynamicStyle(for: componentName, function: selectedStyleFunction, color: selectedColor, shape: selectedShape, state: selectedState))
            """
        case "Text":
            previewComponent += """
            
                    Text(sampleText)
                        .textStyle(getTextStyle(function: selectedStyleFunction, color: selectedColor))
            """
        case "Divider":
            previewComponent += """
            
                    Divider()
                        .dividerStyle(applyDynamicStyle(for: componentName, function: selectedStyleFunction, color: selectedColor))
            """
        case "Toggle":
            previewComponent += """
            
                    Toggle(sampleText, isOn: $isEnabled)
                        .toggleStyle(applyDynamicStyle(for: componentName, function: selectedStyleFunction, color: selectedColor))
            """
        case "TextField":
            previewComponent += """
            
                    TextField(sampleText, text: .constant(""))
                        .textFieldStyle(applyDynamicStyle(for: componentName, function: selectedStyleFunction,
                            color: selectedColor, hasError: showError),
                            errorMessage: showError ? .constant("Campo com erro") : .constant(""))
            """
        default:
            previewComponent += """
            
                    // Componente genérico usando o estilo selecionado
                    Text(sampleText)
                        .padding()
                        .foregroundColor(colors.color(by: selectedColor))
                        .background(
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(colors.color(by: selectedColor) ?? Color.gray, lineWidth: 1)
                        )
                        .overlay(
                            Text("Estilo: \\(selectedStyleFunction)")
                                .font(fonts.small)
                                .foregroundColor(colors.contentA)
                                .padding(4)
                                .background(Color.white.opacity(0.8))
                                .cornerRadius(4)
                                .padding(4),
                            alignment: .topTrailing
                        )
            """
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
                    
                    // Seletor de função de estilo
                    Picker("Estilo", selection: $selectedStyleFunction) {
                        ForEach(componentInfo.styleFunctions, id: \\.name) { function in
                            Text(function.name).tag(function.name)
                        }
                    }
                    .pickerStyle(.wheel)
                    .frame(height: 100)
            """
        case "Toggle":
            configurationSection += """
                    
                    // Toggle para testar o componente
                    Toggle("Estado do toggle", isOn: $isEnabled)
                        .toggleStyle(.default(.contentA))
                        .padding(.horizontal)
                    
                    // Seletor de função de estilo
                    Picker("Estilo", selection: $selectedStyleFunction) {
                        ForEach(componentInfo.styleFunctions, id: \\.name) { function in
                            Text(function.name).tag(function.name)
                        }
                    }
                    .pickerStyle(.wheel)
                    .frame(height: 100)
            """
        case "Button":
            configurationSection += """
                    
                    // Seletor de função de estilo
                    Picker("Estilo", selection: $selectedStyleFunction) {
                        ForEach(componentInfo.styleFunctions, id: \\.name) { function in
                            Text(function.name).tag(function.name)
                        }
                    }
                    .pickerStyle(.wheel)
                    .frame(height: 100)
                    
                    // Seletor para forma do botão
                    Picker("Forma", selection: $selectedShape) {
                        Text("Arredondado").tag("rounded")
                        Text("Retangular").tag("rectangle")
                        Text("Circular").tag("circle")
                    }
                    .pickerStyle(.segmented)
                    .padding(.horizontal)
                    
                    // Seletor para estado do botão
                    Picker("Estado", selection: $selectedState) {
                        Text("Normal").tag("enabled")
                        Text("Pressionado").tag("pressed")
                        Text("Desabilitado").tag("disabled")
                        Text("Loading").tag("loading")
                    }
                    .pickerStyle(.segmented)
                    .padding(.horizontal)
            """
        case "Divider":
            configurationSection += """
                    
                    // Seletor de função de estilo
                    Picker("Estilo", selection: $selectedStyleFunction) {
                        ForEach(componentInfo.styleFunctions, id: \\.name) { function in
                            Text(function.name).tag(function.name)
                        }
                    }
                    .pickerStyle(.wheel)
                    .frame(height: 100)
            """
        default:
            configurationSection += """
                    
                    // Seletor de função de estilo
                    Picker("Estilo", selection: $selectedStyleFunction) {
                        ForEach(componentInfo.styleFunctions, id: \\.name) { function in
                            Text(function.name).tag(function.name)
                        }
                    }
                    .pickerStyle(.wheel)
                    .frame(height: 100)
            """
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
        .buttonStyle(.\\(selectedStyleFunction)(
            color: .\\(String(describing: selectedColor)),
            shape: .\\(selectedShape)(cornerRadius: 8),
            state: .\\(selectedState)
        ))
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
            .dividerStyle(.\\(selectedStyleFunction)(.\\(String(describing: selectedColor))))
        \"\"\"
        """
        case "Toggle":
            generateCode += """
                code += \"\"\"
        Toggle("\\(sampleText)", isOn: $isEnabled)
            .toggleStyle(.\\(selectedStyleFunction)(.\\(String(describing: selectedColor))))
        \"\"\"
        """
        case "TextField":
            generateCode += """
                code += \"\"\"
        TextField("\\(sampleText)", text: $textValue)
            .textFieldStyle(.\\(selectedStyleFunction)(color: .\\(String(describing: selectedColor))\\(showError ? ", hasError: true" : "")))
        \"\"\"
        """
        default:
            generateCode += """
                code += \"\"\"
        // Código para \(componentName)
        \(componentName)()
            .\(componentName.lowercased())Style(.\\(selectedStyleFunction)(color: .\\(String(describing: selectedColor))))
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
        
        // Substituir helpers específicos por um helper genérico
        var styleHelpers = """
            
            // Helper genérico para aplicar estilos dinâmicos baseados no nome da função
            private func applyDynamicStyle<T>(for component: String, function: String, color: ColorName, shape: String = "rounded", state: String = "enabled", hasError: Bool = false) -> T {
                // Parâmetros específicos para cada tipo de componente
                let buttonShape = component == "Button" ? getButtonShape(shape) : nil
                let buttonState = component == "Button" ? getButtonState(state) : nil
                
                // Usamos KeyPath para acessar a função de estilo apropriada
                switch component {
                case "Button":
                    guard let buttonShape = buttonShape, let buttonState = buttonState else {
                        // Fallback para estilo padrão se não puder construir os parâmetros
                        return (ButtonStyle.contentA(color: color, shape: .rounded(cornerRadius: 8), state: .enabled) as! T)
                    }
                    
                    // Aplicação dinâmica de estilos para Button
                    switch function {
                    case "contentA": return (ButtonStyle.contentA(color: color, shape: buttonShape, state: buttonState) as! T)
                    case "contentB": return (ButtonStyle.contentB(color: color, shape: buttonShape, state: buttonState) as! T)
                    case "contentC": return (ButtonStyle.contentC(color: color, shape: buttonShape, state: buttonState) as! T)
                    case "highlightA": return (ButtonStyle.highlightA(color: color, shape: buttonShape, state: buttonState) as! T)
                    case "backgroundA": return (ButtonStyle.backgroundA(color: color, shape: buttonShape, state: buttonState) as! T)
                    case "backgroundB": return (ButtonStyle.backgroundB(color: color, shape: buttonShape, state: buttonState) as! T)
                    case "backgroundC": return (ButtonStyle.backgroundC(color: color, shape: buttonShape, state: buttonState) as! T)
                    case "backgroundD": return (ButtonStyle.backgroundD(color: color, shape: buttonShape, state: buttonState) as! T)
                    default: return (ButtonStyle.contentA(color: color, shape: buttonShape, state: buttonState) as! T)
                    }
                    
                case "Divider":
                    // Aplicação dinâmica para Divider
                    switch function {
                    case "contentA": return (DividerStyle.contentA(color) as! T)
                    case "contentB": return (DividerStyle.contentB(color) as! T)
                    case "contentC": return (DividerStyle.contentC(color) as! T)
                    case "highlightA": return (DividerStyle.highlightA(color) as! T)
                    case "backgroundA": return (DividerStyle.backgroundA(color) as! T)
                    case "backgroundB": return (DividerStyle.backgroundB(color) as! T)
                    case "backgroundC": return (DividerStyle.backgroundC(color) as! T)
                    case "backgroundD": return (DividerStyle.backgroundD(color) as! T)
                    default: return (DividerStyle.contentA(color) as! T)
                    }
                    
                case "Toggle":
                    // Aplicação dinâmica para Toggle
                    switch function {
                    case "default": return (ToggleStyle.default(color) as! T)
                    case "contentA": return (ToggleStyle.contentA(color) as! T)
                    case "contentB": return (ToggleStyle.contentB(color) as! T)
                    case "contentC": return (ToggleStyle.contentC(color) as! T)
                    case "highlightA": return (ToggleStyle.highlightA(color) as! T)
                    case "backgroundA": return (ToggleStyle.backgroundA(color) as! T)
                    case "backgroundB": return (ToggleStyle.backgroundB(color) as! T)
                    case "backgroundC": return (ToggleStyle.backgroundC(color) as! T)
                    case "backgroundD": return (ToggleStyle.backgroundD(color) as! T)
                    default: return (ToggleStyle.default(color) as! T)
                    }
                    
                case "TextField":
                    // Aplicação dinâmica para TextField
                    switch function {
                    case "default": return (TextFieldStyle.default(color: color, hasError: hasError) as! T)
                    case "contentA": return (TextFieldStyle.contentA(color: color, hasError: hasError) as! T)
                    case "contentB": return (TextFieldStyle.contentB(color: color, hasError: hasError) as! T)
                    case "contentC": return (TextFieldStyle.contentC(color: color, hasError: hasError) as! T)
                    case "highlightA": return (TextFieldStyle.highlightA(color: color, hasError: hasError) as! T)
                    case "backgroundA": return (TextFieldStyle.backgroundA(color: color, hasError: hasError) as! T)
                    case "backgroundB": return (TextFieldStyle.backgroundB(color: color, hasError: hasError) as! T)
                    case "backgroundC": return (TextFieldStyle.backgroundC(color: color, hasError: hasError) as! T)
                    case "backgroundD": return (TextFieldStyle.backgroundD(color: color, hasError: hasError) as! T)
                    default: return (TextFieldStyle.default(color: color, hasError: hasError) as! T)
                    }
                    
                default:
                    // Se não for um dos componentes nativos conhecidos, tenta através de reflection (não implementado)
                    fatalError("Estilo não suportado para o componente \\(component)")
                }
            }
        """
        
        // Manter os helpers específicos do Button para converter shape e state
        if componentName == "Button" {
            styleHelpers += """
            
            // Helper para obter a forma do botão
            private func getButtonShape(_ shape: String) -> ButtonShape {
                switch shape {
                case "rounded":
                    return .rounded(cornerRadius: 8)
                case "rectangle":
                    return .rectangle
                case "circle":
                    return .circle
                default:
                    return .rounded(cornerRadius: 8)
                }
            }
            
            // Helper para obter o estado do botão
            private func getButtonState(_ state: String) -> DSState {
                switch state {
                case "enabled":
                    return .enabled
                case "pressed":
                    return .pressed
                case "disabled":
                    return .disabled
                case "loading":
                    return .loading
                default:
                    return .enabled
                }
            }
            """
        }
        
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
        fullContent += styleEnums
        fullContent += "\n}"  // Fechar a struct
        
        return fullContent
    }
    
    func generateGetStyle(with componentInfo: ComponentInfo) -> String {
        let name = componentInfo.name.capitalized
        let teste = """
            private func get\(name)Style(function: String, color: ColorName) -> some \(name)Style {
                switch function {
                    \(componentInfo.styleFunctions.map { $0.name })
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
        
        return teste
    }
}
