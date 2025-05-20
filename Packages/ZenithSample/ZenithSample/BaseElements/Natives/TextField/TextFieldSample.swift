import SFSafeSymbols
import SwiftUI
import Zenith
import ZenithCoreInterface

struct TextFieldSample: View, @preconcurrency BaseThemeDependencies {
    @Dependency(\.themeConfigurator) var themeConfigurator
    @State private var sampleText = "Exemplo de texto"

    @State private var style: GenerateTextFieldSampleEnum = .contentA

    @State private var state: DSState = .enabled

    @State private var errorMessage: String = "Sample text"

    @State private var placeholder: String = "Sample text"

    @State private var hasError: Bool = false

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
            TextField("", text: $sampleText)
                .textFieldStyle(getTextFieldStyle(style.rawValue), placeholder: placeholder, hasError: hasError, errorMessage: $errorMessage)
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
            EnumSelector<GenerateTextFieldSampleEnum>(
                title: "TextField Estilos",
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
            TextField("", text: $errorMessage)
                .textFieldStyle(.contentA(), placeholder: "errorMessage")
                .padding(.horizontal)
            TextField("", text: $placeholder)
                .textFieldStyle(.contentA(), placeholder: "placeholder")
                .padding(.horizontal)
            Toggle("hasError", isOn: $hasError)
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
                    ForEach(TextFieldStyleCase.allCases, id: \.self) { style in
                        VStack {
                            TextField("", text: $sampleText)
                                .textFieldStyle(style.style(), placeholder: placeholder, hasError: hasError, errorMessage: $errorMessage)
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
        let styleFunctionsCases = [".contentA(.\(state.rawValue))", ".contentC(.\(state.rawValue))", ".highlightA(.\(state.rawValue))"]
        let selectedStyle = styleFunctionsCases.first(where: { $0.contains(style.rawValue) }) ?? ".\(style.rawValue)()"
        code += """
        TextField("", text: .constant("\(sampleText)"))
        .textFieldStyle(\(selectedStyle), placeholder: "\(placeholder)", hasError: \(hasError), errorMessage: .constant("\(errorMessage)"))
        """
        return code
    }

    private func getTextFieldStyle(_ style: String) -> AnyTextFieldStyle {
        let style: any Zenith.TextFieldStyle = switch style {
        case "contentA":
            .contentA(state)
        case "contentC":
            .contentC(state)
        case "highlightA":
            .highlightA(state)
        default:
            .contentA(state)
        }
        return AnyTextFieldStyle(style)
    }
}

enum GenerateTextFieldSampleEnum: String, CaseIterable, Identifiable {
    public var id: Self { self }

    case contentA
    case contentC
    case highlightA
}
