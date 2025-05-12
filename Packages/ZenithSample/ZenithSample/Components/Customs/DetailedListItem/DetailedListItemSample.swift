import SwiftUI
import Zenith
import ZenithCoreInterface

struct DetailedListItemSample: View, @preconcurrency BaseThemeDependencies {
    @Dependency(\.themeConfigurator) var themeConfigurator
    @State var isExpanded = false
    @State private var progressValue: Double = 0.75
    @State private var showText: Bool = true
    @State private var animated: Bool = true
    @State private var size: Double = 30
    @State private var isFloating: Bool = false // Inicialmente não está flutuando
    
    // Valores para configuração avançada do blur
    @State private var blur1Width: Double = 42
    @State private var blur1Height: Double = 24
    @State private var blur1Radius: Double = 20
    @State private var blur1OffsetX: Double = -25
    @State private var blur1OffsetY: Double = 25
    @State private var blur1Opacity: Double = 0.9
    
    @State private var blur2Width: Double = 80
    @State private var blur2Height: Double = 40
    @State private var blur2Radius: Double = 40
    @State private var blur2OffsetX: Double = -20
    @State private var blur2OffsetY: Double = 20
    @State private var blur2Opacity: Double = 1.0
    
    @State private var blur3Width: Double = 100
    @State private var blur3Height: Double = 50
    @State private var blur3Radius: Double = 50
    @State private var blur3OffsetX: Double = -20
    @State private var blur3OffsetY: Double = 20
    @State private var blur3Opacity: Double = 1.0
    
    // Options to control the display
    enum ProgressDisplayMode: String, CaseIterable, Identifiable {
        case text = "Texto"
        case simpleProgress = "Progresso Simples"
        case detailedProgress = "Progresso Detalhado"
        case customProgress = "Progresso Customizado"
        case customContent = "Conteúdo Personalizado"
        
        var id: String { self.rawValue }
    }
    
    // Selected color for the component style
    @State private var selectedColor: ColorName = .highlightA
    @State private var selectedMode: ProgressDisplayMode = .text
    @State private var customText: String = "Feito hoje"
    @State private var descriptionText: String = "Frequência: 5 vezes na semana"
    @State private var showDescription: Bool = true
    @State private var showFloatingOption: Bool = true // Opção para mostrar a configuração flutuante
    
    var body: some View {
        ZStack {
            // Conteúdo principal com ScrollView
            ScrollView {
                VStack(alignment: .leading, spacing: spacings.medium) {
                    // Título da amostra
                    Text("DetailedListItem")
                        .font(fonts.largeBold)
                        .foregroundColor(colors.contentA)
                        .padding(.top, spacings.small)
                        .padding(.horizontal, spacings.small)
                    
                    // Componente DetailedListItem no topo da tela
                    VStack(alignment: .leading) {
                        Text("Preview - Clique no card para abrir floating")
                            .font(fonts.mediumBold)
                            .foregroundColor(colors.contentA)
                            .padding(.horizontal, spacings.small)
                        
                        // Preview do componente com interação de clique
                        currentDetailedListItem
                            .makeWindowFloating(
                                isFloating: $isFloating,
                                backgroundColor: colors.backgroundB
                            )
                                
                    }
                    .padding(.vertical, spacings.small)
                    .background(colors.backgroundB)
                    .animation(.easeInOut(duration: 0.2), value: isFloating)
                    
                    // Configurações
                    VStack(alignment: .leading) {
                        Text("Configurações do Componente")
                            .font(fonts.mediumBold)
                            .foregroundColor(colors.contentA)
                            .padding(.bottom, spacings.small)
                        
                        // Color selector for the style
                        ColorSelector(selectedColor: $selectedColor)
                            .padding(.bottom, spacings.small)
                        
                        // Display mode selector using GridSelector
                        GridSelector(
                            title: "Display Mode",
                            selection: $selectedMode,
                            columnsCount: 2,
                            height: 140
                        )
                        .padding(.bottom, spacings.small)
                        
                        // Description settings
                        VStack(alignment: .leading, spacing: spacings.small) {
                            Text("Description")
                                .font(fonts.smallBold)
                                .foregroundColor(colors.contentA)
                            
                            Toggle("Show Description", isOn: $showDescription)
                                .toggleStyle(.default(.highlightA))
                                .foregroundColor(colors.contentA)
                            
                            if showDescription {
                                TextField("Description text", text: $descriptionText)
                                    .textFieldStyle(.roundedBorder)
                            }
                        }
                        .padding(.bottom, spacings.medium)
                        
                        // Settings based on the selected mode
                        if selectedMode == .text {
                            Text("Progress Text")
                                .font(fonts.smallBold)
                                .foregroundColor(colors.contentA)
                                .padding(.bottom, 4)
                            
                            TextField("Progress text", text: $customText)
                                .textFieldStyle(.roundedBorder)
                                .padding(.bottom, spacings.small)
                        }
                        
                        if selectedMode == .simpleProgress ||
                            selectedMode == .detailedProgress ||
                            selectedMode == .customProgress {
                            
                            VStack(spacing: spacings.small) {
                                HStack {
                                    Text("Progress: \(Int(progressValue * 100))%")
                                        .font(fonts.small)
                                        .foregroundColor(colors.contentA)
                                    Spacer()
                                }
                                
                                Slider(value: $progressValue, in: 0...1, step: 0.01)
                                    .accentColor(colors.highlightA)
                                
                                if selectedMode == .detailedProgress || selectedMode == .customProgress {
                                    HStack {
                                        Text("Size: \(Int(size))px")
                                            .font(fonts.small)
                                            .foregroundColor(colors.contentA)
                                        Spacer()
                                    }
                                    
                                    Slider(value: $size, in: 20...60, step: 1)
                                        .accentColor(colors.highlightA)
                                    
                                    Toggle("Show text", isOn: $showText)
                                        .toggleStyle(.default(.highlightA))
                                        .foregroundColor(colors.contentA)
                                    
                                    Toggle("Animated", isOn: $animated)
                                        .toggleStyle(.default(.highlightA))
                                        .foregroundColor(colors.contentA)
                                }
                            }
                            .padding(.bottom, spacings.small)
                        }
                        
                        // Editor avançado de blur
                        BlurConfigEditor(
                            blur1Width: $blur1Width,
                            blur1Height: $blur1Height,
                            blur1Radius: $blur1Radius,
                            blur1OffsetX: $blur1OffsetX,
                            blur1OffsetY: $blur1OffsetY,
                            blur1Opacity: $blur1Opacity,
                            
                            blur2Width: $blur2Width,
                            blur2Height: $blur2Height,
                            blur2Radius: $blur2Radius,
                            blur2OffsetX: $blur2OffsetX,
                            blur2OffsetY: $blur2OffsetY,
                            blur2Opacity: $blur2Opacity,
                            
                            blur3Width: $blur3Width,
                            blur3Height: $blur3Height,
                            blur3Radius: $blur3Radius,
                            blur3OffsetX: $blur3OffsetX,
                            blur3OffsetY: $blur3OffsetY,
                            blur3Opacity: $blur3Opacity
                        )
                        .padding(.bottom, spacings.small)
                    }
                    .padding(.horizontal, spacings.small)
                    
                    // Using the reusable component for code preview
                    CodePreviewSection(generateCode: generateCode)
                        .padding(.top, spacings.medium)
                }
                .onTapGesture {
                    isFloating = false
                }
            }
        }
    }
    
    // View que retorna o DetailedListItem atual com base nas configurações
    private var currentDetailedListItem: some View {
        Group {
            switch selectedMode {
            case .text:
                DetailedListItem(
                    title: "Treino de Adaptação",
                    description: showDescription ? descriptionText : "",
                    leftInfo: .init(
                        title: "Dias",
                        description: "3x"
                    ),
                    rightInfo: .init(
                        title: "Exercícios",
                        description: "5x"
                    ),
                    action: {
                        // Ativar floating ao clicar no botão de ação
                        withAnimation {
                            isFloating.toggle()
                        }
                    },
                    progressText: customText,
                    blurConfig: createCurrentBlurConfig()
                )
                .detailedListItemStyle(.default(selectedColor))
                
            case .simpleProgress:
                DetailedListItem(
                    title: "Treino de Força",
                    description: showDescription ? descriptionText : "",
                    leftInfo: .init(
                        title: "Dias",
                        description: "4x"
                    ),
                    rightInfo: .init(
                        title: "Exercícios",
                        description: "8x"
                    ),
                    action: {
                        // Ativar floating ao clicar no botão de ação
                        withAnimation {
                            isFloating = true
                        }
                    },
                    progress: progressValue,
                    blurConfig: createCurrentBlurConfig()
                )
                .detailedListItemStyle(.default(selectedColor))
                
            case .detailedProgress:
                DetailedListItem(
                    title: "Treino Avançado",
                    description: showDescription ? descriptionText : "",
                    leftInfo: .init(
                        title: "Dias",
                        description: "6x"
                    ),
                    rightInfo: .init(
                        title: "Exercícios",
                        description: "12x"
                    ),
                    action: {
                        if showFloatingOption {
                            withAnimation {
                                isFloating = true
                            }
                        } else {
                            print("Action with detailed parameters")
                        }
                    },
                    progress: progressValue,
                    size: size,
                    showText: showText,
                    animated: animated,
                    blurConfig: createCurrentBlurConfig()
                )
                .detailedListItemStyle(.default(selectedColor))
                
            case .customProgress:
                DetailedListItem(
                    title: "Treino Customizado",
                    description: showDescription ? descriptionText : "",
                    leftInfo: .init(
                        title: "Dias",
                        description: "5x"
                    ),
                    rightInfo: .init(
                        title: "Exercícios",
                        description: "10x"
                    ),
                    action: {
                        if showFloatingOption {
                            withAnimation {
                                isFloating = true
                            }
                        } else {
                            print("Action with custom configuration")
                        }
                    },
                    progressConfig: CircularProgressStyleConfiguration(
                        text: "\(Int(progressValue * 100))%",
                        progress: progressValue,
                        size: size,
                        showText: showText,
                        isAnimating: false,
                        animated: animated
                    ),
                    blurConfig: createCurrentBlurConfig()
                )
                .detailedListItemStyle(.default(selectedColor))
                
            case .customContent:
                DetailedListItem(
                    title: "Treino Cardiovascular",
                    description: showDescription ? descriptionText : "",
                    leftInfo: .init(
                        title: "Dias",
                        description: "2x"
                    ),
                    rightInfo: .init(
                        title: "Exercícios",
                        description: "6x"
                    ),
                    action: {
                        if showFloatingOption {
                            withAnimation {
                                isFloating = true
                            }
                        } else {
                            print("Action with custom content")
                        }
                    },
                    blurConfig: createCurrentBlurConfig()
                ) {
                    VStack(alignment: .trailing) {
                        Text("Conteúdo")
                            .textStyle(.medium(.attention))
                        Text("Personalizado")
                            .textStyle(.smallBold(.danger))
                    }
                }
                .detailedListItemStyle(.default(selectedColor))
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, spacings.small)
    }
    
    // Cria um BlurConfig com os valores atuais definidos nos sliders
    private func createCurrentBlurConfig() -> BlurConfig {
        return BlurConfig(
            blur1Width: blur1Width,
            blur1Height: blur1Height,
            blur1Radius: blur1Radius,
            blur1OffsetX: blur1OffsetX,
            blur1OffsetY: blur1OffsetY,
            blur1Opacity: blur1Opacity,
            
            blur2Width: blur2Width,
            blur2Height: blur2Height,
            blur2Radius: blur2Radius,
            blur2OffsetX: blur2OffsetX,
            blur2OffsetY: blur2OffsetY,
            blur2Opacity: blur2Opacity,
            
            blur3Width: blur3Width,
            blur3Height: blur3Height,
            blur3Radius: blur3Radius,
            blur3OffsetX: blur3OffsetX,
            blur3OffsetY: blur3OffsetY,
            blur3Opacity: blur3Opacity
        )
    }
    
    private func generateCode() -> String {
        let progressValueString = String(format: "%.2f", progressValue)
        let sizeInt = Int(size)
        let showTextString = showText ? "true" : "false"
        let animatedString = animated ? "true" : "false"
        let descriptionParam = showDescription ? "\"\(descriptionText)\"" : "\"\""
        
        // Código para flutuação em window
        let floatingCode = """
        
        // Estado para controlar a flutuação quando clicado
        @State private var isFloating: Bool = false
        
        // Função para ativar o floating ao clicar
        func ativarFloating() {
            withAnimation {
                isFloating = true
            }
        }
        
        // Envolver o componente em um Button para detectar cliques no card
        Button(action: {
            ativarFloating()
        }) {
            // Seu componente DetailedListItem aqui
        }
        .buttonStyle(PlainButtonStyle())
        
        // Aplicar o floating em window
        .makeWindowFloating(
            isFloating: $isFloating,
            backgroundOpacity: 0.7,
            backgroundBlur: 10,
            scale: 1.0,
            isDraggable: true
        )
        """
        
        switch selectedMode {
        case .text:
            return """
            // Criar um BlurConfig personalizado
            let customBlurConfig = BlurConfig(
                blur1Width: \(Int(blur1Width)),
                blur1Height: \(Int(blur1Height)),
                blur1Radius: \(Int(blur1Radius)),
                blur1OffsetX: \(Int(blur1OffsetX)),
                blur1OffsetY: \(Int(blur1OffsetY)),
                blur1Opacity: \(String(format: "%.2f", blur1Opacity)),
                
                blur2Width: \(Int(blur2Width)),
                blur2Height: \(Int(blur2Height)),
                blur2Radius: \(Int(blur2Radius)),
                blur2OffsetX: \(Int(blur2OffsetX)),
                blur2OffsetY: \(Int(blur2OffsetY)),
                blur2Opacity: \(String(format: "%.2f", blur2Opacity)),
                
                blur3Width: \(Int(blur3Width)),
                blur3Height: \(Int(blur3Height)),
                blur3Radius: \(Int(blur3Radius)),
                blur3OffsetX: \(Int(blur3OffsetX)),
                blur3OffsetY: \(Int(blur3OffsetY)),
                blur3Opacity: \(String(format: "%.2f", blur3Opacity))
            )
            DetailedListItem(
                title: "Treino de Adaptação",
                description: \(descriptionParam),
                leftInfo: .init(
                    title: "Dias",
                    description: "3x"
                ),
                rightInfo: .init(
                    title: "Exercícios",
                    description: "5x"
                ),
                action: {
                    withAnimation {
                        isFloating = true
                    }
                },
                progressText: "\(customText)",
                blurConfig: customBlurConfig
            )
            .detailedListItemStyle(.default(.\(selectedColor.rawValue)))\(floatingCode)
            """
            
        case .simpleProgress:
            return """
            // Criar um BlurConfig personalizado
            let customBlurConfig = BlurConfig(
                blur1Width: \(Int(blur1Width)),
                blur1Height: \(Int(blur1Height)),
                blur1Radius: \(Int(blur1Radius)),
                blur1OffsetX: \(Int(blur1OffsetX)),
                blur1OffsetY: \(Int(blur1OffsetY)),
                blur1Opacity: \(String(format: "%.2f", blur1Opacity)),
                
                blur2Width: \(Int(blur2Width)),
                blur2Height: \(Int(blur2Height)),
                blur2Radius: \(Int(blur2Radius)),
                blur2OffsetX: \(Int(blur2OffsetX)),
                blur2OffsetY: \(Int(blur2OffsetY)),
                blur2Opacity: \(String(format: "%.2f", blur2Opacity)),
                
                blur3Width: \(Int(blur3Width)),
                blur3Height: \(Int(blur3Height)),
                blur3Radius: \(Int(blur3Radius)),
                blur3OffsetX: \(Int(blur3OffsetX)),
                blur3OffsetY: \(Int(blur3OffsetY)),
                blur3Opacity: \(String(format: "%.2f", blur3Opacity))
            )
            
            DetailedListItem(
                title: "Treino de Força",
                description: \(descriptionParam),
                leftInfo: .init(
                    title: "Dias",
                    description: "4x"
                ),
                rightInfo: .init(
                    title: "Exercícios",
                    description: "8x"
                ),
                action: {
                    withAnimation {
                        isFloating = true
                    }
                },
                progress: \(progressValueString), // \(Int(progressValue * 100))% progress
                blurConfig: customBlurConfig
            )
            .detailedListItemStyle(.default(.\(selectedColor.rawValue)))\(floatingCode)
            """
            
        case .detailedProgress:
            return """
            // Criar um BlurConfig personalizado
            let customBlurConfig = BlurConfig(
                blur1Width: \(Int(blur1Width)),
                blur1Height: \(Int(blur1Height)),
                blur1Radius: \(Int(blur1Radius)),
                blur1OffsetX: \(Int(blur1OffsetX)),
                blur1OffsetY: \(Int(blur1OffsetY)),
                blur1Opacity: \(String(format: "%.2f", blur1Opacity)),
                
                blur2Width: \(Int(blur2Width)),
                blur2Height: \(Int(blur2Height)),
                blur2Radius: \(Int(blur2Radius)),
                blur2OffsetX: \(Int(blur2OffsetX)),
                blur2OffsetY: \(Int(blur2OffsetY)),
                blur2Opacity: \(String(format: "%.2f", blur2Opacity)),
                
                blur3Width: \(Int(blur3Width)),
                blur3Height: \(Int(blur3Height)),
                blur3Radius: \(Int(blur3Radius)),
                blur3OffsetX: \(Int(blur3OffsetX)),
                blur3OffsetY: \(Int(blur3OffsetY)),
                blur3Opacity: \(String(format: "%.2f", blur3Opacity))
            )
            
            DetailedListItem(
                title: "Treino Avançado",
                description: \(descriptionParam),
                leftInfo: .init(
                    title: "Dias",
                    description: "6x"
                ),
                rightInfo: .init(
                    title: "Exercícios",
                    description: "12x"
                ),
                action: {
                    withAnimation {
                        isFloating = true
                    }
                },
                progress: \(progressValueString),
                size: \(sizeInt),
                showText: \(showTextString),
                animated: \(animatedString),
                blurConfig: customBlurConfig
            )
            .detailedListItemStyle(.default(.\(selectedColor.rawValue)))\(floatingCode)
            """
            
        case .customProgress:
            return """
            // Criar um BlurConfig personalizado
            let customBlurConfig = BlurConfig(
                blur1Width: \(Int(blur1Width)),
                blur1Height: \(Int(blur1Height)),
                blur1Radius: \(Int(blur1Radius)),
                blur1OffsetX: \(Int(blur1OffsetX)),
                blur1OffsetY: \(Int(blur1OffsetY)),
                blur1Opacity: \(String(format: "%.2f", blur1Opacity)),
                
                blur2Width: \(Int(blur2Width)),
                blur2Height: \(Int(blur2Height)),
                blur2Radius: \(Int(blur2Radius)),
                blur2OffsetX: \(Int(blur2OffsetX)),
                blur2OffsetY: \(Int(blur2OffsetY)),
                blur2Opacity: \(String(format: "%.2f", blur2Opacity)),
                
                blur3Width: \(Int(blur3Width)),
                blur3Height: \(Int(blur3Height)),
                blur3Radius: \(Int(blur3Radius)),
                blur3OffsetX: \(Int(blur3OffsetX)),
                blur3OffsetY: \(Int(blur3OffsetY)),
                blur3Opacity: \(String(format: "%.2f", blur3Opacity))
            )
            
            DetailedListItem(
                title: "Treino Customizado",
                description: \(descriptionParam),
                leftInfo: .init(
                    title: "Dias",
                    description: "5x"
                ),
                rightInfo: .init(
                    title: "Exercícios",
                    description: "10x"
                ),
                action: {
                    withAnimation {
                        isFloating = true
                    }
                },
                progressConfig: CircularProgressStyleConfiguration(
                    text: "\(Int(progressValue * 100))%",
                    progress: \(progressValueString),
                    size: \(sizeInt),
                    showText: \(showTextString),
                    isAnimating: false,
                    animated: \(animatedString)
                ),
                blurConfig: customBlurConfig
            )
            .detailedListItemStyle(.default(.\(selectedColor.rawValue)))\(floatingCode)
            """
            
        case .customContent:
            return """
            // Criar um BlurConfig personalizado
            let customBlurConfig = BlurConfig(
                blur1Width: \(Int(blur1Width)),
                blur1Height: \(Int(blur1Height)),
                blur1Radius: \(Int(blur1Radius)),
                blur1OffsetX: \(Int(blur1OffsetX)),
                blur1OffsetY: \(Int(blur1OffsetY)),
                blur1Opacity: \(String(format: "%.2f", blur1Opacity)),
                
                blur2Width: \(Int(blur2Width)),
                blur2Height: \(Int(blur2Height)),
                blur2Radius: \(Int(blur2Radius)),
                blur2OffsetX: \(Int(blur2OffsetX)),
                blur2OffsetY: \(Int(blur2OffsetY)),
                blur2Opacity: \(String(format: "%.2f", blur2Opacity)),
                
                blur3Width: \(Int(blur3Width)),
                blur3Height: \(Int(blur3Height)),
                blur3Radius: \(Int(blur3Radius)),
                blur3OffsetX: \(Int(blur3OffsetX)),
                blur3OffsetY: \(Int(blur3OffsetY)),
                blur3Opacity: \(String(format: "%.2f", blur3Opacity))
            )
            
            DetailedListItem(
                title: "Treino Cardiovascular",
                description: \(descriptionParam),
                leftInfo: .init(
                    title: "Dias",
                    description: "2x"
                ),
                rightInfo: .init(
                    title: "Exercícios",
                    description: "6x"
                ),
                action: {
                    withAnimation {
                        isFloating = true
                    }
                },
                blurConfig: customBlurConfig
            ) {
                VStack(alignment: .trailing) {
                    Text("Conteúdo Personalizado")
                        .textStyle(.medium(.attention))
                    Text("O que precisar")
                        .textStyle(.smallBold(.danger))
                }
            }
            .detailedListItemStyle(.default(.\(selectedColor.rawValue)))\(floatingCode)
            """
        }
    }
}
