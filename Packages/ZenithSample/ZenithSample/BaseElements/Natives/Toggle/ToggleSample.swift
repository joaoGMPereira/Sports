import SwiftUI
import Zenith
import ZenithCoreInterface

struct ToggleSample: View, @preconcurrency BaseThemeDependencies {
    @Dependency(\.themeConfigurator) var themeConfigurator
    @State private var sampleText = "Exemplo de texto"

    @State private var style: GenerateToggleSampleEnum = .small

    @State private var color: ColorName = .highlightA

    @State private var isOn: Bool = false
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
            Toggle(sampleText, isOn: $isOn)
                .toggleStyle(getToggleStyle(style.rawValue))
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
            EnumSelector<GenerateToggleSampleEnum>(
                title: "Toggle Estilos",
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
            Toggle("isOn", isOn: $isOn)
                .toggleStyle(.default(.highlightA))
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
                    ForEach(ToggleStyleCase.allCases, id: \.self) { style in
                        VStack {
                            Toggle(sampleText, isOn: $isOn)
                                .toggleStyle(style.style())
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
        let styleFunctionsCases = [".small(.\(color.rawValue))", ".default(.\(color.rawValue))"]
        let selectedStyle = styleFunctionsCases.first(where: { $0.contains(style.rawValue) }) ?? ".\(style.rawValue)()"
        code += """
        Toggle("\(sampleText)", isOn: $isOn)
        .toggleStyle(\(selectedStyle))
        """
        return code
    }

    private func getToggleStyle(_ style: String) -> AnyToggleStyle {
        let style: any ToggleStyle = switch style {
        case "small":
            .small(color)

        case "default":
            .default(color)

        default:
            .small(color)
        }
        return AnyToggleStyle(style)
    }
}

enum GenerateToggleSampleEnum: String, CaseIterable, Identifiable {
    public var id: Self { self }

    case small
    case `default`
}
