import SwiftUI
import Zenith
import ZenithCoreInterface

struct ButtonSample: View, @preconcurrency BaseThemeDependencies {
    @Dependency(\.themeConfigurator) var themeConfigurator
    
    @State private var buttonText = "Button Text"
    @State private var selectedStyle = ButtonStyleCase.contentA
    @State private var searchText = ""
    
    var body: some View {
        VStack(spacing: 16) {
            // Preview do botão com estilo selecionado
            VStack {
                Button(action: {
                    print("Button tapped")
                }) {
                    Text(selectedStyle.rawValue.lowercased().contains("circle") ? String(buttonText.prefix(1)) : buttonText)
                        .padding(spacings.extraSmall)
                }
                .buttonStyle(selectedStyle.style())
                .frame(maxWidth: .infinity)
            }
            .frame(maxWidth: .infinity, alignment: .center)
            .padding()
            .background(
                // Aplica o backgroundC se for tipo card
                selectedStyle == .cardAppearanceFill || selectedStyle == .cardAppearanceBordered || 
                selectedStyle == .cardAppearanceFillDisabled || selectedStyle == .cardAppearanceBorderedDisabled ? 
                    colors.backgroundC : Color.clear
            )
            .cornerRadius(16)
            
            Divider().padding(.top)
            
            configurationSection
        }
        .padding(.horizontal)
    }
    
    var configurationSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            TextField("Texto do botão", text: $buttonText)
                .textFieldStyle(.roundedBorder)
            
            // Estilo
            VStack(alignment: .leading) {
                Text("Estilo")
                TextField("Filtrar estilos", text: $searchText)
                    .textFieldStyle(.roundedBorder)
                
                    ScrollView {
                        LazyVGrid(columns: [
                            GridItem(.adaptive(minimum: 80, maximum: 100), spacing: 16)
                        ], spacing: 16) {
                            ForEach(filteredButtonStyles, id: \.self) { style in
                                styleButton(style)
                            }
                        }
                        .padding()
                    }
            }
        }
        .padding(.top, 8)
    }
    
    @ViewBuilder
    private func styleButton(_ style: ButtonStyleCase) -> some View {
        Text(style.id)
            .font(fonts.small)
            .padding(.horizontal, 10)
            .padding(.vertical, 6)
            .background(
                RoundedRectangle(cornerRadius: 8)
                    .fill(selectedStyle == style ? colors.highlightA : colors.backgroundB)
            )
            .foregroundColor(selectedStyle == style ? colors.contentC : colors.contentA)
            .onTapGesture {
                selectedStyle = style
            }
    }
    
    var filteredButtonStyles: [ButtonStyleCase] {
        if searchText.isEmpty {
            return ButtonStyleCase.allCases
        }
        return ButtonStyleCase.allCases.filter {
            $0.id.lowercased().contains(searchText.lowercased())
        }
    }
}
