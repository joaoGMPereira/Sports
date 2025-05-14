import SwiftUI
import Zenith
import ZenithCoreInterface

struct DeComponentSample: View, @preconcurrency BaseThemeDependencies {
    @Dependency(\.themeConfigurator) var themeConfigurator
    @State private var showFixedHeader = false
    @State private var selectedStyle: DeComponentStyleCase = .contentA
    @State private var componentText = "Sample DeComponent"
    
    var body: some View {
        SampleWithFixedHeader(
            showFixedHeader: $showFixedHeader,
            content: {
                Card(action: {
                    showFixedHeader.toggle()
                }) {
                    VStack(spacing: 16) {
                        // Exibe o componente com o estilo selecionado
                        DeComponent(componentText)
                            .decomponentStyle(selectedStyle.style())
                            .padding()
                            .frame(maxWidth: .infinity)
                    }
                    .padding()
                }
                .padding()
            },
            config: {
                VStack(alignment: .leading, spacing: 16) {
                    Text("Configurações")
                        .font(fonts.mediumBold)
                        .foregroundColor(colors.contentA)
                    
                    // Campo para editar o texto do componente
                    TextField("Texto do componente", text: $componentText)
                        .textFieldStyle(.roundedBorder)
                        .padding(.bottom, 8)
                    
                    // Usando o EnumSelector para selecionar o estilo
                    EnumSelector(
                        title: "Estilo do DeComponent",
                        selection: $selectedStyle,
                        columnsCount: 2,
                        height: 80,
                        itemLabel: { getStyleLabel($0) }
                    )
                    
                    Divider().padding(.vertical, 8)
                    
                    // Visualização de todos os estilos disponíveis
                    Text("Todos os estilos disponíveis:")
                        .font(fonts.smallBold)
                        .foregroundColor(colors.contentA)
                    
                    VStack(spacing: 12) {
                        ForEach(DeComponentStyleCase.allCases, id: \.self) { style in
                            HStack {
                                Text(getStyleLabel(style))
                                    .font(fonts.small)
                                    .foregroundColor(colors.contentA)
                                
                                Spacer()
                                
                                DeComponent("Exemplo")
                                    .decomponentStyle(style.style())
                            }
                            .padding(.vertical, 4)
                        }
                    }
                    .padding()
                    .background(colors.backgroundB.opacity(0.3))
                    .cornerRadius(8)
                    
                    Spacer(minLength: 20)
                    
                    CodePreviewSection(generateCode: generateCode)
                }
                .padding()
            }
        )
    }
    
    private func getStyleLabel(_ style: DeComponentStyleCase) -> String {
        switch style {
        case .contentA:
            return "Content A"
        case .contentB:
            return "Content B"
        }
    }
    
    private func generateCode() -> String {
        """
        DeComponent("\(componentText)")
            .decomponentStyle(.\(String(describing: selectedStyle))())
        """
    }
}
