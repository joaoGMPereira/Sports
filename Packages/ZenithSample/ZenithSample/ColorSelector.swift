import SwiftUI
import Zenith
import ZenithCoreInterface

struct ColorSelector: View, @preconcurrency BaseThemeDependencies {
    @Dependency(\.themeConfigurator) var themeConfigurator
    @Binding var selectedColor: ColorName
    var title: String = "Cor do Texto"
    
    var body: some View {
        VStack(alignment: .leading) {
            Text(title)
                .textStyle(.largeBold(.contentA))
                .padding(.horizontal)
            
            ScrollView(.vertical, showsIndicators: false) {
                LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 4), count: 3), spacing: 4) {
                    ForEach(ColorName.allCases, id: \.self) { colorName in
                        colorButton(for: colorName)
                    }
                }
            }
            .frame(height: 100)
        }
    }
    
    private func colorButton(for colorName: ColorName) -> some View {
        Button(action: {
            selectedColor = colorName
        }) {
            VStack(spacing: 4) {
                // Amostra da cor
                Circle()
                    .fill(colors.color(by: colorName) ?? .clear)
                    .frame(width: 24, height: 24)
                    .overlay(
                        Circle()
                            .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                    )
                
                Text(colorName.rawValue)
                    .textStyle(.small(selectedColor == colorName ? .highlightA : .contentA))
                    .lineLimit(1)
                    .minimumScaleFactor(0.8)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 8)
            .background(
                RoundedRectangle(cornerRadius: 8)
                    .fill(selectedColor == colorName ? colors.highlightA.opacity(0.2) : colors.backgroundB)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(selectedColor == colorName ? colors.highlightA : colors.backgroundC, lineWidth: 1)
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
}
