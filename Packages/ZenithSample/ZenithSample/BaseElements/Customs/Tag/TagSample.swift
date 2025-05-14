import SwiftUI
import Zenith
import ZenithCoreInterface

struct TagSample: View, @preconcurrency BaseThemeDependencies {
    @Dependency(\.themeConfigurator) var themeConfigurator
    
    @State private var showFixedHeader = false
    @State private var tagText = "Tag"
    
    var body: some View {
        SampleWithFixedHeader(
            showFixedHeader: $showFixedHeader,
            content: {
                Card(action: {
                    showFixedHeader.toggle()
                }) {
                    HStack(spacing: 12) {
                        Tag(tagText)
                            .tagStyle(.default(.default))
                    }
                    .padding()
                }
                .padding()
            },
            config: {
                ScrollView {
                    VStack(alignment: .leading, spacing: 20) {
                        Text("Configurações")
                            .font(fonts.mediumBold)
                            .foregroundColor(colors.contentA)
                        
                        // Configuração do texto
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Texto")
                                .font(fonts.smallBold)
                                .foregroundColor(colors.contentA)
                            TextField("Texto da tag", text: $tagText)
                                .textFieldStyle(.contentA())
                                .padding(.top, 4)
                        }
                        .padding()
                        .background(colors.backgroundB.opacity(0.3))
                        .cornerRadius(8)
                        
                        // Exemplos de estilos
                        Text("Estilos")
                            .font(fonts.mediumBold)
                            .foregroundColor(colors.contentA)
                            .padding(.top, 16)
                        
                        VStack(alignment: .leading, spacing: 16) {
                            ForEach(TagStyleCase.allCases) { style in
                                HStack {
                                    Text(String(describing: style))
                                        .font(fonts.small)
                                        .foregroundColor(colors.contentA)
                                        .frame(width: 120, alignment: .leading)
                                    
                                    Tag(tagText)
                                        .tagStyle(style.style())
                                }
                                .padding(.vertical, 4)
                            }
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
            }
        )
    }
    
    private func generateCode() -> String {
        return """
        Tag("\(tagText)")
            .tagStyle(.default(.highlightA))
        """
    }
}
