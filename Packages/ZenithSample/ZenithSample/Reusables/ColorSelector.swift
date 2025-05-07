import SwiftUI
import Zenith
import ZenithCoreInterface

struct ColorSelector: View, @preconcurrency BaseThemeDependencies {
    @Dependency(\.themeConfigurator) var themeConfigurator
    @Binding var selectedColor: ColorName
    
    var body: some View {
        VStack(alignment: .leading) {
            Text("Estilo de Cor")
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
            Text(colorName.rawValue)
                .textStyle(.small(selectedColor == colorName ? .highlightA : .contentA))
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
