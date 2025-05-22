import SFSafeSymbols
import SwiftUI
import Zenith
import ZenithCoreInterface

struct ButtonSample: View, @preconcurrency BaseThemeDependencies {
    @Dependency(\.themeConfigurator) var themeConfigurator
    @State private var sampleText = "Exemplo de texto"

    @State private var style: GenerateButtonSampleEnum = .contentA

    @State private var state: DSState = .enabled

    @State private var type: CardType = .fill

    @State private var shape: ButtonShape = .rounded(cornerRadius: .infinity)

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
            Button(sampleText) {
                // Ação do botão
            }
            .buttonStyle(getButtonStyle(style.rawValue))
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

            EnumSelector<GenerateButtonSampleEnum>(
                title: "Button Estilos",
                selection: $style,
                columnsCount: 3,
                height: 120
            )
            .padding(.horizontal)
            EnumSelector<DSState>(
                title: "DSState",
                selection: $state,
                columnsCount: 3,
                height: 120
            )
            .padding(.horizontal)
            EnumSelector<CardType>(
                title: "CardType",
                selection: $type,
                columnsCount: 3,
                height: 120
            )
            .padding(.horizontal)
            EnumSelector<ButtonShape>(
                title: "ButtonShape",
                selection: $shape,
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
                    ForEach(ButtonStyleCase.allCases, id: \.self) { style in
                        VStack {
                            Button(sampleText) {
                                // Ação do botão
                            }
                            .buttonStyle(style.style())
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
        let styleFunctionsCases = [".contentA(shape: .\(shape.rawValue), state: .\(state.rawValue))", ".highlightA(shape: .\(shape.rawValue), state: .\(state.rawValue))", ".backgroundD(shape: .\(shape.rawValue), state: .\(state.rawValue))", ".cardAppearance(.\(type.rawValue), state: .\(state.rawValue))"]
        let selectedStyle = styleFunctionsCases.first(where: { $0.contains(style.rawValue) }) ?? ".\(style.rawValue)()"
        code += """
        Button("\(sampleText)") {
            // Ação do botão
        }
        .buttonStyle(\(selectedStyle))
        """
        return code
    }

    private func getButtonStyle(_ style: String) -> AnyButtonStyle {
        let style: any ButtonStyle = switch style {
        case "contentA":
            .contentA(shape: shape, state: state)
        case "highlightA":
            .highlightA(shape: shape, state: state)
        case "backgroundD":
            .backgroundD(shape: shape, state: state)
        case "cardAppearance":
            .cardAppearance(type, state: state)
        default:
            .contentA(shape: shape, state: state)
        }
        return AnyButtonStyle(style)
    }
}

enum GenerateButtonSampleEnum: String, CaseIterable, Identifiable {
    public var id: Self { self }

    case contentA
    case highlightA
    case backgroundD
    case cardAppearance
}
