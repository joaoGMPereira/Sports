import SFSafeSymbols
import SwiftUI
import Zenith
import ZenithCoreInterface

@MainActor
struct DetailedListItemSample: View, @preconcurrency BaseThemeDependencies {
    @Dependency(\.themeConfigurator) var themeConfigurator
    @State private var style: GenerateDetailedListItemSampleEnum = .default

    @State private var selectedInit: GenerateDetailedListItemInitEnum = .title_description_0

    @State private var title: String = "Sample text"

    @State private var description: String = .init()

    @State private var leftInfo: DetailedListItemInfo = .init()

    @State private var rightInfo: DetailedListItemInfo = .init()

    @State private var blurConfig: BlurConfig = .standard()

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

                ComplexTypeEditor(
                    componentType: .struct,
                    value: $leftInfo,
                    completion: processComplexTypeChanges(_:)
                )
                .padding(.vertical, 8)
                .onChange(of: leftInfo) { oldValue, newValue in
                    print(newValue)
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

                ComplexTypeEditor(
                    componentType: .struct,
                    value: $rightInfo,
                    completion: processComplexTypeChanges(_:)
                )
                .padding(.vertical, 8)
                .onChange(of: rightInfo) { oldValue, newValue in
                    print("rightInfo atualizado: \(newValue)")
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

                ComplexTypeEditor(
                    componentType: .struct,
                    value: $blurConfig,
                    completion: processComplexTypeChanges(_:)
                )
                .padding(.vertical, 8)
                .onChange(of: blurConfig) { oldValue, newValue in
                    print("blurConfig atualizado: \(newValue)")
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
            initCode = "DetailedListItem(title: \"\(title)\", description: \"\(description)\", leftInfo: \(leftInfo), rightInfo: \(rightInfo), blurConfig: \(blurConfig), action: {})"
        case .title_description_2:
            initCode = "DetailedListItem(title: \"\(title)\", description: \"\(description)\", leftInfo: \(leftInfo), rightInfo: \(rightInfo), blurConfig: \(blurConfig), action: {}, trailingContent: {})"
        case .title_description_3:
            initCode = "DetailedListItem(title: \"\(title)\", description: \"\(description)\", leftInfo: \(leftInfo), rightInfo: \(rightInfo), action: {}, progressText: \"\(progressText)\", blurConfig: \(blurConfig))"
        case .title_description_4:
            initCode = "DetailedListItem(title: \"\(title)\", description: \"\(description)\", leftInfo: \(leftInfo), rightInfo: \(rightInfo), action: {}, progress: \(progress), size: \(size), showText: \(showText), animated: \(animated), blurConfig: \(blurConfig))"
        case .title_description_5:
            initCode = "DetailedListItem(title: \"\(title)\", description: \"\(description)\", leftInfo: \(leftInfo), rightInfo: \(rightInfo), action: {})"
        case .title_description_6:
            initCode = "DetailedListItem(title: \"\(title)\", description: \"\(description)\", leftInfo: \(leftInfo), rightInfo: \(rightInfo), action: {}, blurConfig: \(blurConfig))"
        case .title_description_7:
            initCode = "DetailedListItem(title: \"\(title)\", description: \"\(description)\", leftInfo: \(leftInfo), rightInfo: \(rightInfo), action: {}, blurConfig: \(blurConfig))"
        case .title_description_8:
            initCode = "DetailedListItem(title: \"\(title)\", description: \"\(description)\", leftInfo: \(leftInfo), rightInfo: \(rightInfo), action: {}, blurConfig: \(blurConfig), trailingContent: {})"
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
    
    // Método para processar as alterações recebidas via NotificationCenter
    private func processComplexTypeChanges(_ properties: [String: Any]) {
        guard
              let properties = properties["properties"] as? [[String: Any]] else {
            return
        }
        // Exibir todas as propriedades modificadas para debug
        print("Propriedades alteradas via NotificationCenter: \(properties)")
        
        // Processar as modificações das propriedades
        for property in properties {
            if let name = property["name"] as? String,
               let type = property["type"] as? String {
                print("Propriedade modificada: \(name) do tipo \(type)")
                
                // Aqui você pode adicionar lógica específica para cada propriedade
                if name == "title" && property["value"] is String {
                    // Exemplo de processamento específico para uma propriedade
                    print("Título foi atualizado")
                }
            }
        }
        
        // Outras ações possíveis:
        // - Validar os valores
        // - Sincronizar com um backend
        // - Atualizar outras partes da sua UI
        // - Salvar os valores em armazenamento persistente
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
