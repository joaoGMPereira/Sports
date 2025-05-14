import SwiftUI
import Zenith
import ZenithCoreInterface

struct ToggleSample: View, @preconcurrency BaseThemeDependencies {
    @Dependency(\.themeConfigurator) var themeConfigurator
    
    @State var isOn = false
    @State var showFixedHeader = false
    @State private var selectedColor: ColorName = .highlightA
    
    var body: some View {
        SampleWithFixedHeader(
            showFixedHeader: $showFixedHeader,
            content: {
                Card(action: {
                    showFixedHeader.toggle()
                }) {
                    Toggle("Toggle de exemplo", isOn: $isOn)
                        .toggleStyle(.default(selectedColor))
                        .padding()
                }
                .padding()
            },
            config: {
                VStack(alignment: .leading, spacing: 20) {
                    Text("Configurações")
                        .font(fonts.mediumBold)
                        .foregroundColor(colors.contentA)
                        .padding(.bottom, 8)
                    
                    // Seletor de cor
                    ColorSelector(selectedColor: $selectedColor)
                        .padding(.bottom, 16)
                    
                    // Estado atual
                    Toggle("Ligado", isOn: $isOn)
                        .toggleStyle(.default(.highlightA))
                        .padding(.bottom, 24)
                    
                    // Exemplos de estilos
                    Text("Estilos de Toggle")
                        .font(fonts.mediumBold)
                        .foregroundColor(colors.contentA)
                        .padding(.bottom, 8)
                    
                    VStack(spacing: 20) {
                        ForEach(ToggleStyleCase.allCases, id: \.self) { style in
                            VStack(alignment: .leading, spacing: 8) {
                                Text(String(describing: style))
                                    .font(fonts.small)
                                    .foregroundColor(colors.contentA)
                                
                                Toggle("Toggle \(String(describing: style))", isOn: $isOn)
                                    .toggleStyle(style.style())
                            }
                            .padding()
                            .background(colors.backgroundB.opacity(0.3))
                            .cornerRadius(8)
                        }
                    }
                    
                    // Exemplos de estados
                    Text("Estados")
                        .font(fonts.mediumBold)
                        .foregroundColor(colors.contentA)
                        .padding(.vertical, 8)
                    
                    VStack(spacing: 16) {
                        Toggle("Toggle normal", isOn: $isOn)
                            .toggleStyle(.default(selectedColor))
                        
                        Toggle("Toggle desabilitado (On)", isOn: .constant(true))
                            .toggleStyle(.default(selectedColor))
                            .disabled(true)
                        
                        Toggle("Toggle desabilitado (Off)", isOn: .constant(false))
                            .toggleStyle(.default(selectedColor))
                            .disabled(true)
                    }
                    .padding()
                    .background(colors.backgroundB.opacity(0.3))
                    .cornerRadius(8)
                    
                    // Código para implementação
                    CodePreviewSection(generateCode: generateCode)
                        .padding(.top, 16)
                }
                .padding()
            }
        )
    }
    
    private func generateCode() -> String {
        """
        @State var isOn = \(isOn)
        
        Toggle("Toggle de exemplo", isOn: $isOn)
            .toggleStyle(.default(.\(selectedColor.rawValue)))
        """
    }
}
