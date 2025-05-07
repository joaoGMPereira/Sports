import SwiftUI
import Zenith
import ZenithCoreInterface

struct FontSelector: View, @preconcurrency BaseThemeDependencies {
    @Dependency(\.themeConfigurator) var themeConfigurator
    @Binding var selectedFont: FontName
    
    var body: some View {
        VStack(alignment: .leading) {
            Text("Estilo da Fonte")
                .textStyle(.largeBold(.contentA))
                .padding(.horizontal)
            
            ScrollView(.vertical, showsIndicators: false) {
                LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 4), count: 2), spacing: 8) {
                    ForEach(FontName.allCases, id: \.self) { fontType in
                        fontButton(for: fontType)
                    }
                }
            }
            .frame(height: 120)
        }
    }
    
    private func fontButton(for fontType: FontName) -> some View {
        Button(action: {
            selectedFont = fontType
        }) {
            Text(fontType.description)
                .font(fonts.small)
                .foregroundColor(selectedFont == fontType ? colors.highlightA : colors.contentA)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 8)
                .background(
                    RoundedRectangle(cornerRadius: 8)
                        .fill(selectedFont == fontType ? colors.highlightA.opacity(0.2) : colors.backgroundB)
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(selectedFont == fontType ? colors.highlightA : colors.backgroundC, lineWidth: 1)
                )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// Extensão para fornecer descrições legíveis para o FontName
extension FontName {
    var description: String {
        switch self {
        case .small: return "Pequeno"
        case .smallBold: return "Pequeno Bold"
        case .medium: return "Médio"
        case .mediumBold: return "Médio Bold"
        case .large: return "Grande"
        case .largeBold: return "Grande Bold"
        case .bigBold: return "Extra Grande"
        }
    }
}
