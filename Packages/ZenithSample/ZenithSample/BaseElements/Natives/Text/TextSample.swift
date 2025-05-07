import SwiftUI
import Zenith
import ZenithCoreInterface

struct TextSample: View, @preconcurrency BaseThemeDependencies {
    @Dependency(\.themeConfigurator) var themeConfigurator
    
    @State var isExpanded = false
    @State private var sampleText = "Lorem ipsum dolor sit amet"
    @State private var selectedColor: ColorName = .contentA
    @State private var selectedFont: FontName = .medium
    @State private var selectedStyle = TextStyleCase.mediumContentA
    @State private var showAllStyles = false
    @State private var useContrastBackground = true
    @State private var copySuccess = false
    
    var body: some View {
        SectionView(
            title: "TEXT",
            isExpanded: $isExpanded
        ) {
            VStack(spacing: 16) {
                // Preview do texto com configurações atuais
                previewText
                
                Divider().padding(.vertical, 4)
                
                // Área de configuração
                configurationSection
                
                // Botões para gerar código
                codeGenerationButtons
                
                // Preview do código gerado
                codePreviewSection
                
                // Exibição de todos os estilos (opcional)
                if showAllStyles {
                    Divider().padding(.vertical, 4)
                    
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Todos os Estilos de Texto")
                            .font(fonts.mediumBold)
                            .foregroundColor(colors.contentA)
                        
                        ScrollView {
                            VStack(alignment: .leading, spacing: 8) {
                                ForEach(TextStyleCase.allCases, id: \.self) { style in
                                    Text("\(String(describing: style))")
                                        .textStyle(style.style())
                                        .padding(.vertical, 4)
                                        .padding(.horizontal, 8)
                                        .background(
                                            RoundedRectangle(cornerRadius: 4)
                                                .fill(colors.backgroundB.opacity(0.5))
                                        )
                                }
                            }
                        }
                        .frame(maxHeight: 200)
                    }
                }
            }
            .padding(.horizontal)
        }
    }
    
    // Preview do texto com as configurações selecionadas
    private var previewText: some View {
        VStack {
            Text(sampleText)
                .font(fonts.font(by: selectedFont) ?? fonts.medium)
                .foregroundColor(colors.color(by: selectedColor) ?? colors.contentA)
                .multilineTextAlignment(.center)
                .padding()
                .frame(maxWidth: .infinity)
                .background(
                    RoundedRectangle(cornerRadius: 8)
                        .fill(useContrastBackground ? contrastBackground : colors.backgroundB.opacity(0.2))
                )
        }
    }
    
    // Área de configuração
    private var configurationSection: some View {
        VStack(spacing: 16) {
            // Campo para editar o texto de exemplo
            TextField("Texto de exemplo", text: $sampleText)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding(.horizontal)
            
            // Seletor de fonte
            FontSelector(selectedFont: $selectedFont)
            
            // Seletor de cor
            ColorSelector(selectedColor: $selectedColor)
            
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
    
    // Botões para gerar e copiar código
    private var codeGenerationButtons: some View {
        VStack(spacing: 12) {
                Button(copySuccess ? "Código Copiado!" : "Copiar Código") {
                    UIPasteboard.general.string = generateSwiftCode()
                    withAnimation {
                        copySuccess = true
                    }
                    
                    // Reset após 2 segundos
                    DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                        withAnimation {
                            copySuccess = false
                        }
                    }
                }
                .buttonStyle(copySuccess ? ButtonStyleCase.highlightA.style() : ButtonStyleCase.contentA.style())
                .padding(.vertical, 4)
        }
    }
    
    // Seção de preview do código
    private var codePreviewSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Código Swift:")
                .font(fonts.mediumBold)
                .foregroundColor(colors.contentA)
            
            ScrollView {
                Text(generateSwiftCode())
                    .font(.system(.body, design: .monospaced))
                    .foregroundColor(colors.contentA)
                    .padding()
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(colors.backgroundB.opacity(0.5))
                    .cornerRadius(8)
            }
            .frame(height: 150)
        }
        .transition(.opacity)
    }
    
    // Calcula a cor de fundo contrastante baseada na cor selecionada
    private var contrastBackground: Color {
        switch selectedColor {
        case .contentA, .contentB:
            // Para cores de conteúdo (geralmente claras), use fundo escuro
            return colors.backgroundA
        case .contentC:
            return colors.backgroundC
        case .backgroundA, .backgroundB, .backgroundC:
            // Para cores de fundo (geralmente escuras), use conteúdo claro
            return colors.contentA
        case .backgroundD:
            return colors.highlightA
        case .highlightA:
            // Para cores de destaque, use um fundo complementar
            return colors.contentC
        case .attention, .positive, .danger, .critical:
            // Para cores de status, use um fundo neutro
            return colors.backgroundA
        case .none:
            return colors.none
        }
    }
    
    // Gera o código Swift para o texto configurado
    private func generateSwiftCode() -> String {
        let textStyleName = getTextStyleName()
        
        var code = """
        Text("\(sampleText)")
            .textStyle(.\(textStyleName))
        """
        
        if useContrastBackground {
            code += """
            
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 8)
                    .fill(colors.\(contrastBackgroundColorName))
            )
            """
        }
        code += """
        """
        
        return code
    }
    
    // Helper para obter o nome da cor de background contrastante para o código
    private var contrastBackgroundColorName: String {
        switch selectedColor {
        case .contentA, .contentB:
            return "backgroundA"
        case .contentC:
            return "backgroundC"
        case .backgroundA, .backgroundB, .backgroundC:
            return "contentA"
        case .backgroundD:
            return "highlightA"
        case .highlightA:
            return "contentC"
        case .attention, .positive, .danger, .critical:
            return "backgroundA"
        case .none:
            return "none"
        }
    }
    
    // Helper para obter o nome do TextStyle correspondente
    private func getTextStyleName() -> String {
        // Identificamos o TextStyleCase mais próximo com base na fonte e cor selecionadas
        let fontCaseName: String
        switch selectedFont {
        case .small: fontCaseName = "small"
        case .smallBold: fontCaseName = "smallBold"
        case .medium: fontCaseName = "medium"
        case .mediumBold: fontCaseName = "mediumBold"
        case .large: fontCaseName = "large"
        case .largeBold: fontCaseName = "largeBold"
        case .bigBold: fontCaseName = "bigBold"
        }
        
        // Formate o nome conforme esperado pelo TextStyleCase
        return "\(fontCaseName)(\(selectedColor.rawValue))"
    }
}
