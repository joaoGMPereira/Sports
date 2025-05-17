import SwiftUI
import Zenith
import ZenithCoreInterface

struct DividerSample: View, @preconcurrency BaseThemeDependencies {
    @Dependency(\.themeConfigurator) var themeConfigurator
    @State private var sampleText = "Exemplo de texto"

    @State private var style = "contentA"
    @State private var showAllStyles = false
    @State private var useContrastBackground = true
    @State private var showFixedHeader = false

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

    private var scrollViewWithStyles: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 8) {
                // Mostrar todas as funções de estilo disponíveis
                LazyVGrid(columns: [GridItem(.adaptive(minimum: 160))], spacing: 8) {
                    ForEach(DividerStyleCase.allCases, id: \.self) { style in
                        VStack {
                            Divider()
                                .dividerStyle(style.style())
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

    // Preview do componente com as configurações selecionadas
    private var previewComponent: some View {
        VStack {
            // Preview do componente com as configurações atuais
            Divider()
                .dividerStyle(getDividerStyle(style))
                .padding()
                .frame(maxWidth: .infinity)
                .background(
                    RoundedRectangle(cornerRadius: 8)
                        .fill(useContrastBackground ? colors.backgroundA : colors.backgroundB.opacity(0.2))
                )
        }
    }

    // Área de configuração
    private var configurationSection: some View {
        VStack(spacing: 16) {
            // Campo para texto de exemplo
            TextField("Texto de exemplo", text: $sampleText)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding(.horizontal)
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

    // Gera o código Swift para o componente configurado
    private func generateSwiftCode() -> String {
        var code = "// Código gerado automaticamente\n"
        code += """
        Divider()
        .dividerStyle(.\(style)())
        """
        return code
    }

    private func getDividerStyle(_ style: String) -> AnyDividerStyle {
        let style: any DividerStyle = switch style {
        case "contentA":
            .contentA()
        case "contentC":
            .contentC()
        case "highlightA":
            .highlightA()
        default:
            .contentA()
        }
        return AnyDividerStyle(style)
    }

    // Helper para obter a cor associada a um StyleCase
    private func getColorFromStyle(_ style: some Any) -> ColorName {
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
        if abs(luminance - 0.27) < 0.1 { // 0.27 é aproximadamente a luminosidade de #444444
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
}
