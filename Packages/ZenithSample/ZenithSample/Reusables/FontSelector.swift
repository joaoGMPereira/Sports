import SwiftUI
import Zenith
import ZenithCoreInterface

struct FontSelector: View, @preconcurrency BaseThemeDependencies {
    @Dependency(\.themeConfigurator) var themeConfigurator
    @Binding var selectedFont: FontName
    
    var body: some View {
        EnumSelector(
            title: "Estilo da Fonte",
            selection: $selectedFont,
            columnsCount: 2,
            height: 120,
            itemLabel: { $0.description }
        )
    }
}

// Extensão para fornecer descrições legíveis para o FontName
extension FontName {
    var description: String {
        switch self {
        case .extraSmall: "Extra Pequeno"
        case .extraSmallBold: "Extra Pequeno Bold"
        case .small: "Pequeno"
        case .smallBold: "Pequeno Bold"
        case .medium: "Médio"
        case .mediumBold: "Médio Bold"
        case .large: "Grande"
        case .largeBold: "Grande Bold"
        case .bigBold: "Extra Grande"
        }
    }
}
