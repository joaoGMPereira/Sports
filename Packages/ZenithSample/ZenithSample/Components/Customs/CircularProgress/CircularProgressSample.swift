import SFSafeSymbols
import SwiftUI
import Zenith
import ZenithCoreInterface

struct CircularProgressSample: View, @preconcurrency BaseThemeDependencies {
    @Dependency(\.themeConfigurator) var themeConfigurator
    @State private var style: GenerateCircularProgressSampleEnum = .contentA

    @State private var text: String = "Sample text"

    @State private var progress: Double = 0.01

    @State private var size: CGFloat = 54

    @State private var showText: Bool = true

    @State private var animated: Bool = false

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
            CircularProgress(text: text, progress: progress, size: size, showText: showText, animated: animated)
                .circularProgressStyle(getCircularProgressStyle(style.rawValue))
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
            EnumSelector<GenerateCircularProgressSampleEnum>(
                title: "CircularProgress Estilos",
                selection: $style,
                columnsCount: 3,
                height: 120
            )
            .padding(.horizontal)
            TextField("", text: $text)
                .textFieldStyle(.contentA(), placeholder: "text")
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
                    ForEach(CircularProgressStyleCase.allCases, id: \.self) { style in
                        VStack {
                            CircularProgress(text: text, progress: progress, size: size, showText: showText, animated: animated)
                                .circularProgressStyle(style.style())
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
        let styleFunctionsCases = [".contentA()", ".contentB()", ".highlightA()"]
        let selectedStyle = styleFunctionsCases.first(where: { $0.contains(style.rawValue) }) ?? ".\(style.rawValue)()"
        code += """
        CircularProgress(text: "\(text)", progress: progress, size: size, showText: \(showText), animated: \(animated))
        .circularProgressStyle(\(selectedStyle))
        """
        return code
    }

    private func getCircularProgressStyle(_ style: String) -> AnyCircularProgressStyle {
        let style: any CircularProgressStyle = switch style {
        case "contentA":
            .contentA()
        case "contentB":
            .contentB()
        case "highlightA":
            .highlightA()
        default:
            .contentA()
        }
        return AnyCircularProgressStyle(style)
    }
}

enum GenerateCircularProgressSampleEnum: String, CaseIterable, Identifiable {
    public var id: Self { self }

    case contentA
    case contentB
    case highlightA
}
