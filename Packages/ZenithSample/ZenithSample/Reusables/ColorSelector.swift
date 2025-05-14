import SwiftUI
import Zenith
import ZenithCoreInterface

struct ColorSelector: View, @preconcurrency BaseThemeDependencies {
    @Dependency(\.themeConfigurator) var themeConfigurator
    @Binding var selectedColor: ColorName
    
    var body: some View {
        EnumSelector(
            title: "Estilo de Cor",
            selection: $selectedColor,
            columnsCount: 3,
            height: 100
        )
    }
}
