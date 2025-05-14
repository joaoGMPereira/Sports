import SwiftUI
import Zenith
import ZenithCoreInterface

struct TextFieldSample: View, @preconcurrency BaseThemeDependencies {
    @Dependency(\.themeConfigurator) var themeConfigurator
    
    @State var text = ""
    @State var text2 = ""
    @State var selectedStyle = TextFieldStyleCase.contentA
    @State var showError = false
    @State var showFixedHeader = false
    
    var body: some View {
        SampleWithFixedHeader(
            showFixedHeader: $showFixedHeader,
            content: {
                Card(action: {
                    showFixedHeader.toggle()
                }) {
                    TextField("", text: $text)
                        .textFieldStyle(
                            selectedStyle.style(),
                            placeholder: "Digite seu nome",
                            errorMessage: showError ? .constant("Campo obrigatório") : .constant("")
                        )
                        .padding()
                }
                .padding()
            },
            config: {
                VStack(alignment: .leading, spacing: 20) {
                    Text("Configurações")
                        .font(fonts.mediumBold)
                        .foregroundColor(colors.contentA)
                    
                    // Texto atual
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Texto digitado: \(text.isEmpty ? "(vazio)" : text)")
                            .font(fonts.small)
                            .foregroundColor(colors.contentA)
                        
                        Button(action: {
                            text = ""
                        }) {
                            Text("Limpar")
                                .padding(spacings.extraSmall)
                                .font(fonts.small)
                        }
                        .buttonStyle(.highlightA())
                        .disabled(text.isEmpty)
                    }
                    .padding()
                    .background(colors.backgroundB.opacity(0.3))
                    .cornerRadius(8)
                    
                    // Controle de erro
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Mensagem de erro")
                            .font(fonts.smallBold)
                            .foregroundColor(colors.contentA)
                        
                        Toggle("Mostrar erro", isOn: $showError)
                            .toggleStyle(.default(.highlightA))
                            .foregroundColor(colors.contentA)
                    }
                    .padding()
                    .background(colors.backgroundB.opacity(0.3))
                    .cornerRadius(8)
                    
                    // Seletor de estilos
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Estilo do TextField")
                            .font(fonts.smallBold)
                            .foregroundColor(colors.contentA)
                        
                        ScrollView {
                            VStack(spacing: 8) {
                                ForEach(TextFieldStyleCase.allCases, id: \.self) { style in
                                    HStack {
                                        Text(style.rawValue)
                                            .font(fonts.small)
                                            .foregroundColor(selectedStyle == style ? colors.contentC : colors.contentA)
                                            .tag(style)
                                            .padding(8)
                                            .frame(maxWidth: .infinity, alignment: .leading)
                                            .background(
                                                RoundedRectangle(cornerRadius: 6)
                                                    .fill(selectedStyle == style ? colors.highlightA : colors.backgroundC)
                                            )
                                            .onTapGesture {
                                                selectedStyle = style
                                            }
                                    }
                                }
                            }
                        }
                        .frame(height: 160)
                        .scrollIndicators(.hidden)
                    }
                    .padding()
                    .background(colors.backgroundB.opacity(0.3))
                    .cornerRadius(8)
                    
                    // Exemplos
                    Text("Exemplos")
                        .font(fonts.mediumBold)
                        .foregroundColor(colors.contentA)
                        .padding(.top, 16)
                    
                    // TextField simples
                    VStack(alignment: .leading, spacing: 8) {
                        Text("TextField Simples")
                            .font(fonts.smallBold)
                            .foregroundColor(colors.contentA)
                        
                        TextField("Texto simples", text: $text)
                            .textFieldStyle(selectedStyle.style())
                    }
                    .padding()
                    .background(colors.backgroundB.opacity(0.3))
                    .cornerRadius(8)
                    
                    // TextField com placeholder animado
                    VStack(alignment: .leading, spacing: 8) {
                        Text("TextField com Placeholder Animado")
                            .font(fonts.smallBold)
                            .foregroundColor(colors.contentA)
                        
                        TextField("", text: $text)
                            .textFieldStyle(
                                selectedStyle.style(),
                                placeholder: "Digite seu nome",
                                errorMessage: showError ? .constant("Campo obrigatório") : .constant("")
                            )
                    }
                    .padding()
                    .background(colors.backgroundB.opacity(0.3))
                    .cornerRadius(8)
                    
                    // Segundo TextField com placeholder animado
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Segundo TextField com Placeholder Animado")
                            .font(fonts.smallBold)
                            .foregroundColor(colors.contentA)
                        
                        TextField("", text: $text2)
                            .textFieldStyle(
                                selectedStyle.style(),
                                placeholder: "Digite seu email",
                                errorMessage: showError ? .constant("Campo obrigatório") : .constant("")
                            )
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
        let errorPart = showError ? 
            """
            , errorMessage: .constant("Campo obrigatório")
            """ : ""
        
        return """
        @State var text = "\(text)"
        
        // TextField simples
        TextField("Texto simples", text: $text)
            .textFieldStyle(.\(selectedStyle.rawValue)())
        
        // TextField com placeholder animado
        TextField("", text: $text)
            .textFieldStyle(
                .\(selectedStyle.rawValue)(),
                placeholder: "Digite seu nome"\(errorPart)
            )
        """
    }
}
