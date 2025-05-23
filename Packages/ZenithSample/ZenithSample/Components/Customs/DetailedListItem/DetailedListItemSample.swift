import SFSafeSymbols
import SwiftUI
import Zenith
import ZenithCoreInterface

struct DetailedListItemSample: View, @preconcurrency BaseThemeDependencies {
    @Dependency(\.themeConfigurator) var themeConfigurator
    @State private var style: GenerateDetailedListItemSampleEnum = .default

    @State private var selectedInit: GenerateDetailedListItemInitEnum = .title_description_0

    @State private var title: String = "Sample text"

    @State private var description: String = .init()

    @State private var leftInfo: DetailedListItemInfo = .init()

    @State private var leftInfo_title: String = ""

    @State private var leftInfo_description: String = ""

    // Método para configurar leftInfo com seus parâmetros internos
    private func configureLeftinfo() -> DetailedListItemInfo {
        DetailedListItemInfo(
            title: leftInfo_title,
            description: leftInfo_description
        )
    }

    @State private var rightInfo: DetailedListItemInfo = .init()

    @State private var rightInfo_title: String = ""

    @State private var rightInfo_description: String = ""

    // Método para configurar rightInfo com seus parâmetros internos
    private func configureRightinfo() -> DetailedListItemInfo {
        DetailedListItemInfo(
            title: rightInfo_title,
            description: rightInfo_description
        )
    }

    @State private var blurConfig: BlurConfig = .standard()

    @State private var blurConfig_blur1Width: CGFloat = 42

    @State private var blurConfig_blur1Height: CGFloat = 24

    @State private var blurConfig_blur1Radius: CGFloat = 20

    @State private var blurConfig_blur1OffsetX: CGFloat = -25

    @State private var blurConfig_blur1OffsetY: CGFloat = 25

    @State private var blurConfig_blur1Opacity: Double = 0.9

    @State private var blurConfig_blur2Width: CGFloat = 80

    @State private var blurConfig_blur2Height: CGFloat = 40

    @State private var blurConfig_blur2Radius: CGFloat = 40

    @State private var blurConfig_blur2OffsetX: CGFloat = -20

    @State private var blurConfig_blur2OffsetY: CGFloat = 20

    @State private var blurConfig_blur2Opacity: Double = 1.0

    @State private var blurConfig_blur3Width: CGFloat = 100

    @State private var blurConfig_blur3Height: CGFloat = 50

    @State private var blurConfig_blur3Radius: CGFloat = 50

    @State private var blurConfig_blur3OffsetX: CGFloat = -20

    @State private var blurConfig_blur3OffsetY: CGFloat = 20

    @State private var blurConfig_blur3Opacity: Double = 1.0

    @State private var blurConfig_cornerRadius: CGFloat = 20

    // Método para configurar blurConfig com seus parâmetros internos
    private func configureBlurconfig() -> BlurConfig {
        BlurConfig(
            blur1Width: blurConfig_blur1Width,
            blur1Height: blurConfig_blur1Height,
            blur1Radius: blurConfig_blur1Radius,
            blur1OffsetX: blurConfig_blur1OffsetX,
            blur1OffsetY: blurConfig_blur1OffsetY,
            blur1Opacity: blurConfig_blur1Opacity,
            blur2Width: blurConfig_blur2Width,
            blur2Height: blurConfig_blur2Height,
            blur2Radius: blurConfig_blur2Radius,
            blur2OffsetX: blurConfig_blur2OffsetX,
            blur2OffsetY: blurConfig_blur2OffsetY,
            blur2Opacity: blurConfig_blur2Opacity,
            blur3Width: blurConfig_blur3Width,
            blur3Height: blurConfig_blur3Height,
            blur3Radius: blurConfig_blur3Radius,
            blur3OffsetX: blurConfig_blur3OffsetX,
            blur3OffsetY: blurConfig_blur3OffsetY,
            blur3Opacity: blurConfig_blur3Opacity,
            cornerRadius: blurConfig_cornerRadius
        )
    }

    @State private var action: () -> Void = {}

    private func trailingContent() -> some View { Text("CustomComponent").textStyle(.medium()) }

    @State private var progressText: String = "Sample text"

    @State private var progress: Double = 0.01

    @State private var size: CGFloat = 54

    @State private var showText: Bool = true

    @State private var animated: Bool = true

    @State private var colorName: ColorName = .highlightA

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
            getDetailedListItemInit(selectedInit.rawValue)
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
            VStack(alignment: .leading) {
                Text("DetailedListItem Inicializadores")
                    .font(fonts.smallBold)
                    .foregroundColor(colors.contentA)
                    .padding(.horizontal, 8)

                EnumSelector<GenerateDetailedListItemInitEnum>(
                    title: "Selecione um inicializador",
                    selection: $selectedInit,
                    columnsCount: 1,
                    height: 160
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(colors.highlightA.opacity(0.3), lineWidth: 1)
                )
            }
            .padding(.horizontal)
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
            VStack(alignment: .leading, spacing: 8) {
                Text("leftInfo")
                    .font(fonts.mediumBold)
                    .foregroundColor(colors.contentA)

                Text("DetailedListItemInfo")
                    .font(fonts.small)
                    .foregroundColor(colors.contentB)

                // Campos para propriedades internas
                VStack(alignment: .leading, spacing: 12) {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("title: String")
                            .font(fonts.small)
                            .foregroundColor(colors.contentA)
                        TextField("", text: $leftInfo_title)
                            .textFieldStyle(.contentA(), placeholder: "title")
                            .onChange(of: leftInfo_title) { _ in
                                leftInfo = configureLeftinfo()
                            }
                    }
                    VStack(alignment: .leading, spacing: 4) {
                        Text("description: String")
                            .font(fonts.small)
                            .foregroundColor(colors.contentA)
                        TextField("", text: $leftInfo_description)
                            .textFieldStyle(.contentA(), placeholder: "description")
                            .onChange(of: leftInfo_description) { _ in
                                leftInfo = configureLeftinfo()
                            }
                    }
                }
            }
            .padding()
            .background(colors.backgroundA.opacity(0.5))
            .cornerRadius(8)
            .padding(.horizontal)
            VStack(alignment: .leading, spacing: 8) {
                Text("rightInfo")
                    .font(fonts.mediumBold)
                    .foregroundColor(colors.contentA)

                Text("DetailedListItemInfo")
                    .font(fonts.small)
                    .foregroundColor(colors.contentB)

                // Campos para propriedades internas
                VStack(alignment: .leading, spacing: 12) {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("title: String")
                            .font(fonts.small)
                            .foregroundColor(colors.contentA)
                        TextField("", text: $rightInfo_title)
                            .textFieldStyle(.contentA(), placeholder: "title")
                            .onChange(of: rightInfo_title) { _ in
                                rightInfo = configureRightinfo()
                            }
                    }
                    VStack(alignment: .leading, spacing: 4) {
                        Text("description: String")
                            .font(fonts.small)
                            .foregroundColor(colors.contentA)
                        TextField("", text: $rightInfo_description)
                            .textFieldStyle(.contentA(), placeholder: "description")
                            .onChange(of: rightInfo_description) { _ in
                                rightInfo = configureRightinfo()
                            }
                    }
                }
            }
            .padding()
            .background(colors.backgroundA.opacity(0.5))
            .cornerRadius(8)
            .padding(.horizontal)
            VStack(alignment: .leading, spacing: 8) {
                Text("blurConfig")
                    .font(fonts.mediumBold)
                    .foregroundColor(colors.contentA)

                Text("BlurConfig")
                    .font(fonts.small)
                    .foregroundColor(colors.contentB)

                // Campos para propriedades internas
                VStack(alignment: .leading, spacing: 12) {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("blur1Width: CGFloat")
                            .font(fonts.small)
                            .foregroundColor(colors.contentA)
                        Slider(value: $blurConfig_blur1Width, in: -100 ... 100, step: 0.1)
                            .accentColor(colors.highlightA)
                            .onChange(of: blurConfig_blur1Width) { _ in
                                blurConfig = configureBlurconfig()
                            }
                    }
                    VStack(alignment: .leading, spacing: 4) {
                        Text("blur1Height: CGFloat")
                            .font(fonts.small)
                            .foregroundColor(colors.contentA)
                        Slider(value: $blurConfig_blur1Height, in: -100 ... 100, step: 0.1)
                            .accentColor(colors.highlightA)
                            .onChange(of: blurConfig_blur1Height) { _ in
                                blurConfig = configureBlurconfig()
                            }
                    }
                    VStack(alignment: .leading, spacing: 4) {
                        Text("blur1Radius: CGFloat")
                            .font(fonts.small)
                            .foregroundColor(colors.contentA)
                        Slider(value: $blurConfig_blur1Radius, in: -100 ... 100, step: 0.1)
                            .accentColor(colors.highlightA)
                            .onChange(of: blurConfig_blur1Radius) { _ in
                                blurConfig = configureBlurconfig()
                            }
                    }
                    VStack(alignment: .leading, spacing: 4) {
                        Text("blur1OffsetX: CGFloat")
                            .font(fonts.small)
                            .foregroundColor(colors.contentA)
                        Slider(value: $blurConfig_blur1OffsetX, in: -100 ... 100, step: 0.1)
                            .accentColor(colors.highlightA)
                            .onChange(of: blurConfig_blur1OffsetX) { _ in
                                blurConfig = configureBlurconfig()
                            }
                    }
                    VStack(alignment: .leading, spacing: 4) {
                        Text("blur1OffsetY: CGFloat")
                            .font(fonts.small)
                            .foregroundColor(colors.contentA)
                        Slider(value: $blurConfig_blur1OffsetY, in: -100 ... 100, step: 0.1)
                            .accentColor(colors.highlightA)
                            .onChange(of: blurConfig_blur1OffsetY) { _ in
                                blurConfig = configureBlurconfig()
                            }
                    }
                    VStack(alignment: .leading, spacing: 4) {
                        Text("blur1Opacity: Double")
                            .font(fonts.small)
                            .foregroundColor(colors.contentA)
                        Slider(value: $blurConfig_blur1Opacity, in: -100 ... 100, step: 0.01)
                            .accentColor(colors.highlightA)
                            .onChange(of: blurConfig_blur1Opacity) { _ in
                                blurConfig = configureBlurconfig()
                            }
                    }
                    VStack(alignment: .leading, spacing: 4) {
                        Text("blur2Width: CGFloat")
                            .font(fonts.small)
                            .foregroundColor(colors.contentA)
                        Slider(value: $blurConfig_blur2Width, in: -100 ... 100, step: 0.1)
                            .accentColor(colors.highlightA)
                            .onChange(of: blurConfig_blur2Width) { _ in
                                blurConfig = configureBlurconfig()
                            }
                    }
                    VStack(alignment: .leading, spacing: 4) {
                        Text("blur2Height: CGFloat")
                            .font(fonts.small)
                            .foregroundColor(colors.contentA)
                        Slider(value: $blurConfig_blur2Height, in: -100 ... 100, step: 0.1)
                            .accentColor(colors.highlightA)
                            .onChange(of: blurConfig_blur2Height) { _ in
                                blurConfig = configureBlurconfig()
                            }
                    }
                    VStack(alignment: .leading, spacing: 4) {
                        Text("blur2Radius: CGFloat")
                            .font(fonts.small)
                            .foregroundColor(colors.contentA)
                        Slider(value: $blurConfig_blur2Radius, in: -100 ... 100, step: 0.1)
                            .accentColor(colors.highlightA)
                            .onChange(of: blurConfig_blur2Radius) { _ in
                                blurConfig = configureBlurconfig()
                            }
                    }
                    VStack(alignment: .leading, spacing: 4) {
                        Text("blur2OffsetX: CGFloat")
                            .font(fonts.small)
                            .foregroundColor(colors.contentA)
                        Slider(value: $blurConfig_blur2OffsetX, in: -100 ... 100, step: 0.1)
                            .accentColor(colors.highlightA)
                            .onChange(of: blurConfig_blur2OffsetX) { _ in
                                blurConfig = configureBlurconfig()
                            }
                    }
                    VStack(alignment: .leading, spacing: 4) {
                        Text("blur2OffsetY: CGFloat")
                            .font(fonts.small)
                            .foregroundColor(colors.contentA)
                        Slider(value: $blurConfig_blur2OffsetY, in: -100 ... 100, step: 0.1)
                            .accentColor(colors.highlightA)
                            .onChange(of: blurConfig_blur2OffsetY) { _ in
                                blurConfig = configureBlurconfig()
                            }
                    }
                    VStack(alignment: .leading, spacing: 4) {
                        Text("blur2Opacity: Double")
                            .font(fonts.small)
                            .foregroundColor(colors.contentA)
                        Slider(value: $blurConfig_blur2Opacity, in: -100 ... 100, step: 0.01)
                            .accentColor(colors.highlightA)
                            .onChange(of: blurConfig_blur2Opacity) { _ in
                                blurConfig = configureBlurconfig()
                            }
                    }
                    VStack(alignment: .leading, spacing: 4) {
                        Text("blur3Width: CGFloat")
                            .font(fonts.small)
                            .foregroundColor(colors.contentA)
                        Slider(value: $blurConfig_blur3Width, in: -100 ... 100, step: 0.1)
                            .accentColor(colors.highlightA)
                            .onChange(of: blurConfig_blur3Width) { _ in
                                blurConfig = configureBlurconfig()
                            }
                    }
                    VStack(alignment: .leading, spacing: 4) {
                        Text("blur3Height: CGFloat")
                            .font(fonts.small)
                            .foregroundColor(colors.contentA)
                        Slider(value: $blurConfig_blur3Height, in: -100 ... 100, step: 0.1)
                            .accentColor(colors.highlightA)
                            .onChange(of: blurConfig_blur3Height) { _ in
                                blurConfig = configureBlurconfig()
                            }
                    }
                    VStack(alignment: .leading, spacing: 4) {
                        Text("blur3Radius: CGFloat")
                            .font(fonts.small)
                            .foregroundColor(colors.contentA)
                        Slider(value: $blurConfig_blur3Radius, in: -100 ... 100, step: 0.1)
                            .accentColor(colors.highlightA)
                            .onChange(of: blurConfig_blur3Radius) { _ in
                                blurConfig = configureBlurconfig()
                            }
                    }
                    VStack(alignment: .leading, spacing: 4) {
                        Text("blur3OffsetX: CGFloat")
                            .font(fonts.small)
                            .foregroundColor(colors.contentA)
                        Slider(value: $blurConfig_blur3OffsetX, in: -100 ... 100, step: 0.1)
                            .accentColor(colors.highlightA)
                            .onChange(of: blurConfig_blur3OffsetX) { _ in
                                blurConfig = configureBlurconfig()
                            }
                    }
                    VStack(alignment: .leading, spacing: 4) {
                        Text("blur3OffsetY: CGFloat")
                            .font(fonts.small)
                            .foregroundColor(colors.contentA)
                        Slider(value: $blurConfig_blur3OffsetY, in: -100 ... 100, step: 0.1)
                            .accentColor(colors.highlightA)
                            .onChange(of: blurConfig_blur3OffsetY) { _ in
                                blurConfig = configureBlurconfig()
                            }
                    }
                    VStack(alignment: .leading, spacing: 4) {
                        Text("blur3Opacity: Double")
                            .font(fonts.small)
                            .foregroundColor(colors.contentA)
                        Slider(value: $blurConfig_blur3Opacity, in: -100 ... 100, step: 0.01)
                            .accentColor(colors.highlightA)
                            .onChange(of: blurConfig_blur3Opacity) { _ in
                                blurConfig = configureBlurconfig()
                            }
                    }
                    VStack(alignment: .leading, spacing: 4) {
                        Text("cornerRadius: CGFloat")
                            .font(fonts.small)
                            .foregroundColor(colors.contentA)
                        Slider(value: $blurConfig_cornerRadius, in: -100 ... 100, step: 0.1)
                            .accentColor(colors.highlightA)
                            .onChange(of: blurConfig_cornerRadius) { _ in
                                blurConfig = configureBlurconfig()
                            }
                    }
                }
            }
            .padding()
            .background(colors.backgroundA.opacity(0.5))
            .cornerRadius(8)
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
                            DetailedListItem(title: title, description: description, leftInfo: leftInfo, rightInfo: rightInfo, blurConfig: blurConfig, action: action)
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
        let styleFunctionsCases = [".default(.\(colorName.rawValue))"]
        let selectedStyle = styleFunctionsCases.first(where: { $0.contains(style.rawValue) }) ?? ".\(style.rawValue)()"

        // Gerar código para o inicializador selecionado
        var initCode = ""
        switch selectedInit {
        case .title_description_0:
            initCode = "DetailedListItem(title: \"\(title)\", description: \"\(description)\", leftInfo: DetailedListItemInfo(title: \(leftInfo_title), description: \(leftInfo_description)), rightInfo: DetailedListItemInfo(title: \(rightInfo_title), description: \(rightInfo_description)), blurConfig: BlurConfig(blur1Width: \(blurConfig_blur1Width), blur1Height: \(blurConfig_blur1Height), blur1Radius: \(blurConfig_blur1Radius), blur1OffsetX: \(blurConfig_blur1OffsetX), blur1OffsetY: \(blurConfig_blur1OffsetY), blur1Opacity: \(blurConfig_blur1Opacity), blur2Width: \(blurConfig_blur2Width), blur2Height: \(blurConfig_blur2Height), blur2Radius: \(blurConfig_blur2Radius), blur2OffsetX: \(blurConfig_blur2OffsetX), blur2OffsetY: \(blurConfig_blur2OffsetY), blur2Opacity: \(blurConfig_blur2Opacity), blur3Width: \(blurConfig_blur3Width), blur3Height: \(blurConfig_blur3Height), blur3Radius: \(blurConfig_blur3Radius), blur3OffsetX: \(blurConfig_blur3OffsetX), blur3OffsetY: \(blurConfig_blur3OffsetY), blur3Opacity: \(blurConfig_blur3Opacity), cornerRadius: \(blurConfig_cornerRadius)), action: {})"
        case .title_description_2:
            initCode = "DetailedListItem(title: \"\(title)\", description: \"\(description)\", leftInfo: DetailedListItemInfo(title: \(leftInfo_title), description: \(leftInfo_description)), rightInfo: DetailedListItemInfo(title: \(rightInfo_title), description: \(rightInfo_description)), blurConfig: BlurConfig(blur1Width: \(blurConfig_blur1Width), blur1Height: \(blurConfig_blur1Height), blur1Radius: \(blurConfig_blur1Radius), blur1OffsetX: \(blurConfig_blur1OffsetX), blur1OffsetY: \(blurConfig_blur1OffsetY), blur1Opacity: \(blurConfig_blur1Opacity), blur2Width: \(blurConfig_blur2Width), blur2Height: \(blurConfig_blur2Height), blur2Radius: \(blurConfig_blur2Radius), blur2OffsetX: \(blurConfig_blur2OffsetX), blur2OffsetY: \(blurConfig_blur2OffsetY), blur2Opacity: \(blurConfig_blur2Opacity), blur3Width: \(blurConfig_blur3Width), blur3Height: \(blurConfig_blur3Height), blur3Radius: \(blurConfig_blur3Radius), blur3OffsetX: \(blurConfig_blur3OffsetX), blur3OffsetY: \(blurConfig_blur3OffsetY), blur3Opacity: \(blurConfig_blur3Opacity), cornerRadius: \(blurConfig_cornerRadius)), action: {}, trailingContent: {})"
        case .title_description_3:
            initCode = "DetailedListItem(title: \"\(title)\", description: \"\(description)\", leftInfo: DetailedListItemInfo(title: \(leftInfo_title), description: \(leftInfo_description)), rightInfo: DetailedListItemInfo(title: \(rightInfo_title), description: \(rightInfo_description)), action: {}, progressText: \"\(progressText)\", blurConfig: BlurConfig(blur1Width: \(blurConfig_blur1Width), blur1Height: \(blurConfig_blur1Height), blur1Radius: \(blurConfig_blur1Radius), blur1OffsetX: \(blurConfig_blur1OffsetX), blur1OffsetY: \(blurConfig_blur1OffsetY), blur1Opacity: \(blurConfig_blur1Opacity), blur2Width: \(blurConfig_blur2Width), blur2Height: \(blurConfig_blur2Height), blur2Radius: \(blurConfig_blur2Radius), blur2OffsetX: \(blurConfig_blur2OffsetX), blur2OffsetY: \(blurConfig_blur2OffsetY), blur2Opacity: \(blurConfig_blur2Opacity), blur3Width: \(blurConfig_blur3Width), blur3Height: \(blurConfig_blur3Height), blur3Radius: \(blurConfig_blur3Radius), blur3OffsetX: \(blurConfig_blur3OffsetX), blur3OffsetY: \(blurConfig_blur3OffsetY), blur3Opacity: \(blurConfig_blur3Opacity), cornerRadius: \(blurConfig_cornerRadius)))"
        case .title_description_4:
            initCode = "DetailedListItem(title: \"\(title)\", description: \"\(description)\", leftInfo: DetailedListItemInfo(title: \(leftInfo_title), description: \(leftInfo_description)), rightInfo: DetailedListItemInfo(title: \(rightInfo_title), description: \(rightInfo_description)), action: {}, progress: \(progress), size: \(size), showText: \(showText), animated: \(animated), blurConfig: BlurConfig(blur1Width: \(blurConfig_blur1Width), blur1Height: \(blurConfig_blur1Height), blur1Radius: \(blurConfig_blur1Radius), blur1OffsetX: \(blurConfig_blur1OffsetX), blur1OffsetY: \(blurConfig_blur1OffsetY), blur1Opacity: \(blurConfig_blur1Opacity), blur2Width: \(blurConfig_blur2Width), blur2Height: \(blurConfig_blur2Height), blur2Radius: \(blurConfig_blur2Radius), blur2OffsetX: \(blurConfig_blur2OffsetX), blur2OffsetY: \(blurConfig_blur2OffsetY), blur2Opacity: \(blurConfig_blur2Opacity), blur3Width: \(blurConfig_blur3Width), blur3Height: \(blurConfig_blur3Height), blur3Radius: \(blurConfig_blur3Radius), blur3OffsetX: \(blurConfig_blur3OffsetX), blur3OffsetY: \(blurConfig_blur3OffsetY), blur3Opacity: \(blurConfig_blur3Opacity), cornerRadius: \(blurConfig_cornerRadius)))"
        case .title_description_5:
            initCode = "DetailedListItem(title: \"\(title)\", description: \"\(description)\", leftInfo: DetailedListItemInfo(title: \(leftInfo_title), description: \(leftInfo_description)), rightInfo: DetailedListItemInfo(title: \(rightInfo_title), description: \(rightInfo_description)), action: {})"
        case .title_description_6:
            initCode = "DetailedListItem(title: \"\(title)\", description: \"\(description)\", leftInfo: DetailedListItemInfo(title: \(leftInfo_title), description: \(leftInfo_description)), rightInfo: DetailedListItemInfo(title: \(rightInfo_title), description: \(rightInfo_description)), action: {}, blurConfig: BlurConfig(blur1Width: \(blurConfig_blur1Width), blur1Height: \(blurConfig_blur1Height), blur1Radius: \(blurConfig_blur1Radius), blur1OffsetX: \(blurConfig_blur1OffsetX), blur1OffsetY: \(blurConfig_blur1OffsetY), blur1Opacity: \(blurConfig_blur1Opacity), blur2Width: \(blurConfig_blur2Width), blur2Height: \(blurConfig_blur2Height), blur2Radius: \(blurConfig_blur2Radius), blur2OffsetX: \(blurConfig_blur2OffsetX), blur2OffsetY: \(blurConfig_blur2OffsetY), blur2Opacity: \(blurConfig_blur2Opacity), blur3Width: \(blurConfig_blur3Width), blur3Height: \(blurConfig_blur3Height), blur3Radius: \(blurConfig_blur3Radius), blur3OffsetX: \(blurConfig_blur3OffsetX), blur3OffsetY: \(blurConfig_blur3OffsetY), blur3Opacity: \(blurConfig_blur3Opacity), cornerRadius: \(blurConfig_cornerRadius)))"
        case .title_description_7:
            initCode = "DetailedListItem(title: \"\(title)\", description: \"\(description)\", leftInfo: DetailedListItemInfo(title: \(leftInfo_title), description: \(leftInfo_description)), rightInfo: DetailedListItemInfo(title: \(rightInfo_title), description: \(rightInfo_description)), action: {}, blurConfig: BlurConfig(blur1Width: \(blurConfig_blur1Width), blur1Height: \(blurConfig_blur1Height), blur1Radius: \(blurConfig_blur1Radius), blur1OffsetX: \(blurConfig_blur1OffsetX), blur1OffsetY: \(blurConfig_blur1OffsetY), blur1Opacity: \(blurConfig_blur1Opacity), blur2Width: \(blurConfig_blur2Width), blur2Height: \(blurConfig_blur2Height), blur2Radius: \(blurConfig_blur2Radius), blur2OffsetX: \(blurConfig_blur2OffsetX), blur2OffsetY: \(blurConfig_blur2OffsetY), blur2Opacity: \(blurConfig_blur2Opacity), blur3Width: \(blurConfig_blur3Width), blur3Height: \(blurConfig_blur3Height), blur3Radius: \(blurConfig_blur3Radius), blur3OffsetX: \(blurConfig_blur3OffsetX), blur3OffsetY: \(blurConfig_blur3OffsetY), blur3Opacity: \(blurConfig_blur3Opacity), cornerRadius: \(blurConfig_cornerRadius)))"
        case .title_description_8:
            initCode = "DetailedListItem(title: \"\(title)\", description: \"\(description)\", leftInfo: DetailedListItemInfo(title: \(leftInfo_title), description: \(leftInfo_description)), rightInfo: DetailedListItemInfo(title: \(rightInfo_title), description: \(rightInfo_description)), action: {}, blurConfig: BlurConfig(blur1Width: \(blurConfig_blur1Width), blur1Height: \(blurConfig_blur1Height), blur1Radius: \(blurConfig_blur1Radius), blur1OffsetX: \(blurConfig_blur1OffsetX), blur1OffsetY: \(blurConfig_blur1OffsetY), blur1Opacity: \(blurConfig_blur1Opacity), blur2Width: \(blurConfig_blur2Width), blur2Height: \(blurConfig_blur2Height), blur2Radius: \(blurConfig_blur2Radius), blur2OffsetX: \(blurConfig_blur2OffsetX), blur2OffsetY: \(blurConfig_blur2OffsetY), blur2Opacity: \(blurConfig_blur2Opacity), blur3Width: \(blurConfig_blur3Width), blur3Height: \(blurConfig_blur3Height), blur3Radius: \(blurConfig_blur3Radius), blur3OffsetX: \(blurConfig_blur3OffsetX), blur3OffsetY: \(blurConfig_blur3OffsetY), blur3Opacity: \(blurConfig_blur3Opacity), cornerRadius: \(blurConfig_cornerRadius)), trailingContent: {})"
        }

        code += """
        \(initCode)
        .detailedListItemStyle(\(selectedStyle))
        """
        return code
    }

    private func getDetailedListItemInit(_ initType: String) -> some View {
        switch initType {
        case "title_description_0":
            DetailedListItem(title: title, description: description, leftInfo: leftInfo, rightInfo: rightInfo, blurConfig: blurConfig, action: action)
        case "title_description_2":
            DetailedListItem(title: title, description: description, leftInfo: leftInfo, rightInfo: rightInfo, blurConfig: blurConfig, action: action, trailingContent: trailingContent)
        case "title_description_3":
            DetailedListItem(title: title, description: description, leftInfo: leftInfo, rightInfo: rightInfo, action: action, progressText: progressText, blurConfig: blurConfig)
        case "title_description_4":
            DetailedListItem(title: title, description: description, leftInfo: leftInfo, rightInfo: rightInfo, action: action, progress: progress, size: size, showText: showText, animated: animated, blurConfig: blurConfig)
        case "title_description_5":
            DetailedListItem(title: title, description: description, leftInfo: leftInfo, rightInfo: rightInfo, action: action)
        case "title_description_6":
            DetailedListItem(title: title, description: description, leftInfo: leftInfo, rightInfo: rightInfo, action: action, blurConfig: blurConfig)
        case "title_description_7":
            DetailedListItem(title: title, description: description, leftInfo: leftInfo, rightInfo: rightInfo, action: action, blurConfig: blurConfig)
        case "title_description_8":
            DetailedListItem(title: title, description: description, leftInfo: leftInfo, rightInfo: rightInfo, action: action, blurConfig: blurConfig, trailingContent: trailingContent)
        default:
            DetailedListItem(title: title, description: description, leftInfo: leftInfo, rightInfo: rightInfo, blurConfig: blurConfig, action: action)
        }
    }

    private func getDetailedListItemStyle(_ style: String) -> AnyDetailedListItemStyle {
        let style: any DetailedListItemStyle = switch style {
        case "default":
            .default(colorName)

        default:
            .default(colorName)
        }
        return AnyDetailedListItemStyle(style)
    }
}

enum GenerateDetailedListItemSampleEnum: String, CaseIterable, Identifiable {
    public var id: Self { self }

    case `default`
}

enum GenerateDetailedListItemInitEnum: String, CaseIterable, Identifiable {
    public var id: Self { self }

    case title_description_0
    case title_description_2
    case title_description_3
    case title_description_4
    case title_description_5
    case title_description_6
    case title_description_7
    case title_description_8
}
