import SwiftUI
import Zenith
import ZenithCoreInterface

struct TextSample: View, @preconcurrency BaseThemeDependencies {
    @Dependency(\.themeConfigurator) var themeConfigurator
    @State private var sampleText = "Exemplo de texto"

    @State private var style: GenerateTextSampleEnum = .small

    @State private var color: ColorName = .contentA
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

                            allStyles
                        }
                    }
                }
                .padding(.horizontal)
            }
        )
    }

    // Preview do componente com as configurações selecionadas
    private var previewComponent: some View {
        VStack {
            // Preview do componente com as configurações atuais
            Text(sampleText)
                .textStyle(getTextStyle(style.rawValue))
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
            TextField("", text: $sampleText)
                .textFieldStyle(.contentA(), placeholder: "Texto de exemplo")
                .padding(.horizontal)
            EnumSelector<GenerateTextSampleEnum>(
                title: "Text Estilos",
                selection: $style,
                columnsCount: 3,
                height: 120
            )
            .padding(.horizontal)
            EnumSelector<ColorName>(
                title: "ColorName",
                selection: $color,
                columnsCount: 3,
                height: 120
            )
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

    private var allStyles: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 8) {
                // Mostrar todas as funções de estilo disponíveis
                LazyVGrid(columns: [GridItem(.adaptive(minimum: 160))], spacing: 8) {
                    ForEach(TextStyleCase.allCases, id: \.self) { style in
                        VStack {
                            Text(sampleText)
                                .textStyle(style.style())
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

    // Gera o código Swift para o componente configurado
    private func generateSwiftCode() -> String {
        var code = "// Código gerado automaticamente\n"
        let styleFunctionsCases = [".small(.\(color.rawValue))", ".smallBold(.\(color.rawValue))", ".medium(.\(color.rawValue))", ".mediumBold(.\(color.rawValue))", ".large(.\(color.rawValue))", ".largeBold(.\(color.rawValue))", ".bigBold(.\(color.rawValue))"]
        let selectedStyle = styleFunctionsCases.first(where: { $0.contains(style.rawValue) }) ?? ".\(style.rawValue)()"
        code += """
        Text("\(sampleText)")
        .textStyle(\(selectedStyle))
        """
        return code
    }

    private func getTextStyle(_ style: String) -> AnyTextStyle {
        let style: any TextStyle = switch style {
        case "small":
            .small(color)
        case "smallBold":
            .smallBold(color)
        case "medium":
            .medium(color)
        case "mediumBold":
            .mediumBold(color)
        case "large":
            .large(color)
        case "largeBold":
            .largeBold(color)
        case "bigBold":
            .bigBold(color)
        default:
            .small(color)
        }
        return AnyTextStyle(style)
    }
}

enum GenerateTextSampleEnum: String, CaseIterable, Identifiable {
    public var id: Self { self }

    case small
    case smallBold
    case medium
    case mediumBold
    case large
    case largeBold
    case bigBold
}
