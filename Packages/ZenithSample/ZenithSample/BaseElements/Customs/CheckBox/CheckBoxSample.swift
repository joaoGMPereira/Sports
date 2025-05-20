import SFSafeSymbols
import SwiftUI
import Zenith
import ZenithCoreInterface

struct CheckBoxSample: View, @preconcurrency BaseThemeDependencies {
    @Dependency(\.themeConfigurator) var themeConfigurator
    @State private var style: GenerateCheckBoxSampleEnum = .default

    @State private var isSelected: Bool = false

    @State private var text: String = "Sample text"

    @State private var disabled: Bool = false

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
            CheckBox(isSelected: $isSelected, text: text, disabled: $disabled)
                .checkBoxStyle(getCheckBoxStyle(style.rawValue))
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
            EnumSelector<GenerateCheckBoxSampleEnum>(
                title: "CheckBox Estilos",
                selection: $style,
                columnsCount: 3,
                height: 120
            )
            .padding(.horizontal)
            Toggle("isSelected", isOn: $isSelected)
                .toggleStyle(.default(.highlightA))
                .padding(.horizontal)
            TextField("", text: $text)
                .textFieldStyle(.contentA(), placeholder: "text")
                .padding(.horizontal)
            Toggle("disabled", isOn: $disabled)
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
                    ForEach(CheckBoxStyleCase.allCases, id: \.self) { style in
                        VStack {
                            CheckBox(isSelected: $isSelected, text: text, disabled: $disabled)
                                .checkBoxStyle(style.style())
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
        let styleFunctionsCases = [".default()"]
        let selectedStyle = styleFunctionsCases.first(where: { $0.contains(style.rawValue) }) ?? ".\(style.rawValue)()"
        code += """
        CheckBox(isSelected: .constant(\(isSelected)), text: "\(text)", disabled: .constant(\(disabled)))
        .checkBoxStyle(\(selectedStyle))
        """
        return code
    }

    private func getCheckBoxStyle(_ style: String) -> AnyCheckBoxStyle {
        let style: any CheckBoxStyle = switch style {
        case "default":
            .default()

        default:
            .default()
        }
        return AnyCheckBoxStyle(style)
    }
}

enum GenerateCheckBoxSampleEnum: String, CaseIterable, Identifiable {
    public var id: Self { self }

    case `default`
}
