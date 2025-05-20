import SwiftUI
import Zenith
import ZenithCoreInterface

struct BasicCardSample: View, @preconcurrency BaseThemeDependencies {
    @Dependency(\.themeConfigurator) var themeConfigurator
    @State private var style: GenerateBasicCardSampleEnum = .fill

    @State private var image: String = "Sample text"

    @State private var title: String = "Sample text"

    @State private var arrangement: StackArrangementCase = .verticalCenter

    @State private var contentLayout: CardLayoutCase = .imageText

    @State private var action: (() -> Void) = {}

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
            BasicCard(image: image, title: title, arrangement: arrangement, contentLayout: contentLayout, action: action)
                .basicCardStyle(getBasicCardStyle(style.rawValue))
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
            EnumSelector<GenerateBasicCardSampleEnum>(
                title: "BasicCard Estilos",
                selection: $style,
                columnsCount: 3,
                height: 120
            )
            .padding(.horizontal)
            TextField("", text: $image)
                .textFieldStyle(.contentA(), placeholder: "image")
                .padding(.horizontal)
            TextField("", text: $title)
                .textFieldStyle(.contentA(), placeholder: "title")
                .padding(.horizontal)
            EnumSelector<StackArrangementCase>(
                title: "StackArrangementCase",
                selection: $arrangement,
                columnsCount: 3,
                height: 120
            )
            .padding(.horizontal)
            EnumSelector<CardLayoutCase>(
                title: "CardLayoutCase",
                selection: $contentLayout,
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
                    ForEach(BasicCardStyleCase.allCases, id: \.self) { style in
                        VStack {
                            BasicCard(image: image, title: title, arrangement: arrangement, contentLayout: contentLayout, action: action)
                                .basicCardStyle(style.style())
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
        let styleFunctionsCases = [".fill()", ".bordered()"]
        let selectedStyle = styleFunctionsCases.first(where: { $0.contains(style.rawValue) }) ?? ".\(style.rawValue)()"
        code += """
        BasicCard(image: image, title: title, arrangement: arrangement, contentLayout: contentLayout, action: action)
        .basicCardStyle(\(selectedStyle))
        """
        return code
    }

    private func getBasicCardStyle(_ style: String) -> AnyBasicCardStyle {
        let style: any BasicCardStyle = switch style {
        case "fill":
            .fill()

        case "bordered":
            .bordered()

        default:
            .fill()
        }
        return AnyBasicCardStyle(style)
    }
}

enum GenerateBasicCardSampleEnum: String, CaseIterable, Identifiable {
    public var id: Self { self }

    case fill
    case bordered
}
