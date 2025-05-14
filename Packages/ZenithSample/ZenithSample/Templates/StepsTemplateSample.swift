import SwiftUI
import Zenith
import ZenithCoreInterface

struct StepsTemplateSample: View, @preconcurrency BaseThemeDependencies {
    @State private var selectedStyle: StepsTemplateStyleCase = .default
    @State private var currentStep = 0
    @State private var showFixedHeader = false
    @Dependency(\.themeConfigurator) var themeConfigurator: any ThemeConfiguratorProtocol
    
    var body: some View {
        SampleWithFixedHeader(
            showFixedHeader: $showFixedHeader,
            content: {
                Card(action: {
                    showFixedHeader.toggle()
                }) {
                    VStack {
                        // Content
                        StepsTemplate(
                            totalSteps: 3,
                            currentStep: $currentStep,
                            canMoveToPreviousStep: .constant(true),
                            canMoveToNextStep: .constant(true)
                        ) { step in
                            stepContent(step)
                        }
                        .stepsTemplateStyle(selectedStyle.style())
                        .transition(.opacity)
                        .id("steps-template-\(selectedStyle.rawValue)")
                        .animation(.easeInOut, value: selectedStyle)
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                    }
                    .padding()
                }
                .padding()
            },
            config: {
                VStack(spacing: 16) {
                    Text("Configurações")
                        .font(fonts.largeBold)
                        .foregroundColor(colors.contentA)
                    
                    styleSelectorView
                        .padding(.bottom, 12)
                    
                    Button("Próximo passo") {
                        if currentStep < 2 {
                            currentStep += 1
                        } else {
                            currentStep = 0
                        }
                    }
                    .buttonStyle(.highlightA())
                    .padding(.bottom, 12)
                    
                    CodePreviewSection(generateCode: generateCode)
                }
                .padding()
            }
        )
    }
    
    private var headerView: some View {
        HStack {
            Text("Steps Template")
                .font(fonts.largeBold)
                .foregroundColor(colors.contentA)
            Spacer()
        }
        .padding()
        .background(colors.backgroundB)
    }
    
    private var styleSelectorView: some View {
        Picker("Steps Template", selection: $selectedStyle) {
            ForEach(StepsTemplateStyleCase.allCases, id: \.self) { style in
                Text(style.rawValue).font(fonts.largeBold).tag(style)
            }
        }
        .pickerStyle(SegmentedPickerStyle())
        .introspect(.picker(style: .segmented), on: .iOS(.v17, .v18)) {
            $0.backgroundColor = UIColor.clear
            $0.layer.borderColor = colors.highlightA.uiColor().cgColor
            $0.selectedSegmentTintColor = colors.highlightA.uiColor()
                  $0.layer.borderWidth = 1

            let titleTextAttributes = [
                NSAttributedString.Key.foregroundColor: colors.contentA.uiColor(),
                NSAttributedString.Key.font: UIFont.systemFont(ofSize: 14, weight: .bold)
            ]
            $0.setTitleTextAttributes(
                titleTextAttributes,
                for:.normal
            )

            let titleTextAttributesSelected = [
                NSAttributedString.Key.foregroundColor: colors.contentC.uiColor(),
                NSAttributedString.Key.font: UIFont.systemFont(ofSize: 14, weight: .bold)
            ]
            $0.setTitleTextAttributes(
                titleTextAttributesSelected,
                for:.selected
            )
        }
    }
    
    @ViewBuilder
    private func stepContent(_ step: Int) -> some View {
        switch step {
        case 0:
            stepContentView(
                image: "person.fill",
                imageColor: colors.highlightA,
                title: "Dados Pessoais",
                content: {
                    VStack(alignment: .leading, spacing: 16) {
                        TextField("Nome", text: .constant(""))
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .foregroundColor(colors.contentA)
                        
                        TextField("Email", text: .constant(""))
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .foregroundColor(colors.contentA)
                        
                        TextField("Telefone", text: .constant(""))
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .foregroundColor(colors.contentA)
                    }
                },
                description: "Insira seus dados pessoais para personalizar sua experiência."
            )
        case 1:
            stepContentView(
                image: "dumbbell.fill",
                imageColor: colors.highlightA,
                title: "Objetivo Fitness",
                content: {
                    VStack(alignment: .leading, spacing: 16) {
                        Toggle("Perder peso", isOn: .constant(true))
                            .toggleStyle(.default(.highlightA))
                            .foregroundColor(colors.contentA)
                        Toggle("Ganhar massa muscular", isOn: .constant(false))
                            .toggleStyle(.default(.highlightA))
                            .foregroundColor(colors.contentA)
                        Toggle("Melhorar condicionamento", isOn: .constant(true))
                            .toggleStyle(.default(.highlightA))
                            .foregroundColor(colors.contentA)
                        Toggle("Melhorar flexibilidade", isOn: .constant(false))
                            .toggleStyle(.default(.highlightA))
                            .foregroundColor(colors.contentA)
                    }
                },
                description: "Selecione seus objetivos de treino para receber recomendações adequadas."
            )
        case 2:
            stepContentView(
                image: "checkmark.circle.fill",
                imageColor: colors.highlightA,
                title: "Confirmação",
                content: {
                    VStack(alignment: .leading, spacing: 16) {
                        HStack {
                            Text("Nome:")
                                .fontWeight(.bold)
                                .foregroundColor(colors.contentA)
                            Text("João Silva")
                                .foregroundColor(colors.contentA)
                        }
                        
                        HStack {
                            Text("Email:")
                                .fontWeight(.bold)
                                .foregroundColor(colors.contentA)
                            Text("joao.silva@exemplo.com")
                                .foregroundColor(colors.contentA)
                        }
                        
                        HStack {
                            Text("Objetivos:")
                                .fontWeight(.bold)
                                .foregroundColor(colors.contentA)
                            VStack(alignment: .leading) {
                                Text("• Perder peso")
                                    .foregroundColor(colors.contentA)
                                Text("• Melhorar condicionamento")
                                    .foregroundColor(colors.contentA)
                            }
                        }
                        
                        Button("Finalizar cadastro") {
                            // Ação de finalização
                        }
                        .buttonStyle(.highlightA())
                        .padding(.top)
                    }
                },
                description: "Revise suas informações e confirme para finalizar o processo."
            )
        default:
            Text("Passo não encontrado")
                .foregroundColor(.red)
        }
    }
    
    private func generateCode() -> String {
        """
        StepsTemplate(
            totalSteps: 3,
            currentStep: $currentStep,
            canMoveToPreviousStep: .constant(true),
            canMoveToNextStep: .constant(true)
        ) { step in
            // Conteúdo do passo
            stepContentView(...)
        }
        .stepsTemplateStyle(.\(selectedStyle.rawValue)())
        """
    }
}

// View auxiliar para criar o conteúdo de cada passo
struct stepContentView<Content: View>: View {
    @Dependency(\.themeConfigurator) var themeConfigurator
    
    var colors: any ColorsProtocol {
        themeConfigurator.theme.colors
    }
    
    var fonts: any FontsProtocol {
        themeConfigurator.theme.fonts
    }
    
    let image: String
    let imageColor: Color
    let title: String
    let content: Content
    let description: String
    
    init(
        image: String,
        imageColor: Color,
        title: String,
        @ViewBuilder content: () -> Content,
        description: String
    ) {
        self.image = image
        self.imageColor = imageColor
        self.title = title
        self.content = content()
        self.description = description
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: image)
                    .font(.system(size: 32))
                    .foregroundColor(imageColor)
                
                Text(title)
                    .font(fonts.largeBold)
                    .foregroundColor(colors.contentA)
            }
            
            content
            
            Text(description)
                .font(fonts.small)
                .foregroundColor(colors.contentA.opacity(0.8))
                .padding(.top, 8)
        }
        .padding()
        .frame(maxWidth: .infinity)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(colors.backgroundB)
        )
    }
}

// Extensão para obter descrição dos estilos
extension StepsTemplateStyleCase: CustomStringConvertible, Identifiable, CaseIterable {
    
    public var rawValue: String {
        switch self {
        case .default:
            return "default"
        }
    }
    
    public var description: String {
        switch self {
        case .default:
            return "Padrão"
        }
    }
}

struct StepsTemplateSample_Previews: PreviewProvider {
    static var previews: some View {
        StepsTemplateSample()
    }
}
