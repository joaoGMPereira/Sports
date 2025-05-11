import SwiftUI
import Zenith
import ZenithCoreInterface

struct TextFieldSample: View, @preconcurrency BaseThemeDependencies {
    @Dependency(\.themeConfigurator) var themeConfigurator
    
    @State var isExpanded = false
    @State var text = ""
    @State var text2 = ""
    @State var selectedStyle = TextFieldStyleCase.contentA
    @State var showError = false
    
    var body: some View {
        SectionView(title: "TEXTFIELD", isExpanded: $isExpanded) {
            VStack(spacing: 20) {
                // TextField padrão
                VStack(alignment: .leading, spacing: 8) {
                    Text("TextField Simples")
                        .textStyle(.small(.contentA))
                    
                    TextField("Texto simples", text: $text)
                        .textFieldStyle(selectedStyle.style())
                }
                
                // TextField com placeholder animado
                VStack(alignment: .leading, spacing: 8) {
                    Text("TextField com Placeholder Animado")
                        .textStyle(.small(.contentA))
                    
                    TextField("", text: $text)
                        .textFieldStyle(
                            selectedStyle.style(),
                            placeholder: "Digite seu nome",
                            errorMessage: showError ? .constant("Campo obrigatório") : .constant("")
                        )
                }
                
                // Segundo TextField com placeholder animado
                VStack(alignment: .leading, spacing: 8) {
                    Text("Segundo TextField com Placeholder Animado")
                        .textStyle(.small(.contentA))
                    
                    TextField("", text: $text2)
                        .textFieldStyle(
                            selectedStyle.style(),
                            placeholder: "Digite seu email",
                            errorMessage: showError ? .constant("Campo obrigatório") : .constant("")
                        )
                }
                
                // Botão para alternar mensagens de erro
                Button(action: {
                    showError.toggle()
                }) {
                    Text(showError ? "Ocultar erros" : "Mostrar erros")
                        .padding(spacings.small)
                }
                .buttonStyle(.contentA(shape: .rounded(cornerRadius: 8), state: .enabled))
                .padding(.vertical, spacings.small)
                
                // Seletor de estilos
                ScrollView {
                    VStack {
                        ForEach(TextFieldStyleCase.allCases, id: \.self) { style in
                            Text(style.rawValue).font(fonts.small)
                                .foregroundStyle(selectedStyle == style ? colors.contentC : colors.contentA)
                                .tag(style)
                                .padding(4)
                                .background(
                                    RoundedRectangle(cornerRadius: 4)
                                        .fill(selectedStyle == style ? colors.highlightA : colors.backgroundC)
                                )
                                .onTapGesture {
                                    selectedStyle = style
                                }
                                
                        }
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: 200)
                .scrollIndicators(.hidden)
            }
            .padding(.vertical, spacings.small)
        }
    }
}
