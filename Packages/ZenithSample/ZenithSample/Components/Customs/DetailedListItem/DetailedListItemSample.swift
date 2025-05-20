import SFSafeSymbols
import SwiftUI
import Zenith
import ZenithCoreInterface

struct DetailedListItemSample: View, @preconcurrency BaseThemeDependencies {
    @Dependency(\.themeConfigurator) var themeConfigurator
    @State private var style: GenerateDetailedListItemSampleEnum = .default

    @State private var colorName: ColorName = .highlightA

    @State private var title: String = "Sample text"

    @State private var description: String = .init()

    @State private var leftInfo: Info = .default(colorName: colorName)

    @State private var rightInfo: Info = .default(colorName: colorName)

    @State private var blurConfig: BlurConfig = .standard()

    @State private var action: (() -> Void) = {}

    @State private var progressText: String = "Sample text"

    @State private var progress: Double = 0.01

    @State private var size: CGFloat = 54

    @State private var showText: Bool = true

    @State private var animated: Bool = true

    @State private var e: titl String = .default(colorName: colorName)

    @State private var n: descriptio String = .default(colorName: colorName)

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
            DetailedListItem(title: title, e: e, description: description, n: n, leftInfo: leftInfo, rightInfo: rightInfo, blurConfig: blurConfig, action: action, progressText: progressText, progress: progress, size: size, showText: showText, animated: animated)
                .detailedListItemStyle(getDetailedListItemStyle(style.rawValue))
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
            EnumSelector<GenerateDetailedListItemSampleEnum>(
                title: "DetailedListItem Estilos",
                selection: $style,
                columnsCount: 3,
                height: 120
            )
            .padding(.horizontal)
            EnumSelector<ColorName>(
                title: "ColorName",
                selection: $colorName,
                columnsCount: 3,
                height: 120
            )
            .padding(.horizontal)
            TextField("", text: $title)
                .textFieldStyle(.contentA(), placeholder: "title")
                .padding(.horizontal)
            TextField("", text: $description)
                .textFieldStyle(.contentA(), placeholder: "description")
                .padding(.horizontal)
            EnumSelector<Info>(
                title: "Info",
                selection: $leftInfo,
                columnsCount: 3,
                height: 120
            )
            .padding(.horizontal)
            EnumSelector<Info>(
                title: "Info",
                selection: $rightInfo,
                columnsCount: 3,
                height: 120
            )
            .padding(.horizontal)
            EnumSelector<BlurConfig>(
                title: "BlurConfig",
                selection: $blurConfig,
                columnsCount: 3,
                height: 120
            )
            .padding(.horizontal)
            TextField("", text: $progressText)
                .textFieldStyle(.contentA(), placeholder: "progressText")
                .padding(.horizontal)
            Slider(value: $progress, in: 0 ... 1, step: 0.01)
                .accentColor(colors.highlightA)
                .padding(.horizontal)
            Slider(value: $size, in: 0 ... 100, step: 0.1)
                .accentColor(colors.highlightA)
                .padding(.horizontal)
            Toggle("showText", isOn: $showText)
                .toggleStyle(.default(.highlightA))
                .padding(.horizontal)
            Toggle("animated", isOn: $animated)
                .toggleStyle(.default(.highlightA))
                .padding(.horizontal)
            EnumSelector<titl String>(
                title: "titl String",
                selection: $e,
                columnsCount: 3,
                height: 120
            )
            .padding(.horizontal)
            EnumSelector<descriptio String>(
                title: "descriptio String",
                selection: $n,
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
                    ForEach(DetailedListItemStyleCase.allCases, id: \.self) { style in
                        VStack {
                            DetailedListItem(title: title, e: e, description: description, n: n, leftInfo: leftInfo, rightInfo: rightInfo, blurConfig: blurConfig, action: action, progressText: progressText, progress: progress, size: size, showText: showText, animated: animated)
                                .detailedListItemStyle(style.style())
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
        let styleFunctionsCases = [".default(colorName: .\(colorName.rawValue))"]
        let selectedStyle = styleFunctionsCases.first(where: { $0.contains(style.rawValue) }) ?? ".\(style.rawValue)()"
        code += """
        DetailedListItem(title: "\(title)", e: .\(e.rawValue), description: "\(description)", n: .\(n.rawValue), leftInfo: .\(leftInfo.rawValue), rightInfo: .\(rightInfo.rawValue), blurConfig: .\(blurConfig.rawValue), action: {}, progressText: "\(progressText)", progress: progress, size: size, showText: \(showText), animated: \(animated))
        .detailedListItemStyle(\(selectedStyle))
        """
        return code
    }

    private func getDetailedListItemStyle(_ style: String) -> AnyDetailedListItemStyle {
        let style: any DetailedListItemStyle = switch style {
        case "default":
            .default(colorName: colorName)

        default:
            .default(colorName: colorName)
        }
        return AnyDetailedListItemStyle(style)
    }
}

enum GenerateDetailedListItemSampleEnum: String, CaseIterable, Identifiable {
    public var id: Self { self }

    case `default`
}
