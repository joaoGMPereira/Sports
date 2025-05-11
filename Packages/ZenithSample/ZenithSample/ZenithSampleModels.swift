import SwiftUI
import SFSafeSymbols
import Zenith

// MARK: - Data Models

enum TabType: String, CaseIterable, Identifiable {
    case baseElements = "Base Elements"
    case components = "Components"
    case templates = "Templates"

    var id: String { self.rawValue }

    var icon: SFSymbol {
        switch self {
        case .baseElements: return .squareGrid2x2
        case .components: return .puzzlepieceExtension
        case .templates: return .rectangle3Group
        }
    }
    
    var categories: [ElementCategory] {
        switch self {
        case .baseElements: return [.native, .custom]
        case .components: return [.custom]
        case .templates: return [.template]
        }
    }
}

enum ElementCategory: String, CaseIterable, Identifiable {
    case custom = "Custom"
    case native = "Native"
    case template = "Template"

    var id: String { self.rawValue }
}

enum ElementDisplayType {
    case inline // Mostra o conteúdo diretamente na lista
    case navigation(AnyView) // Navega para outra tela ao clicar
    case section // Funciona como uma seção que pode conter outros elementos
}

struct ElementType: Identifiable {
    var id = UUID()
    var name: String
    var category: ElementCategory
    var tabType: TabType
    var view: AnyView
    var displayType: ElementDisplayType
    
    init<V: View>(name: String, category: ElementCategory, tabType: TabType, view: V, displayType: ElementDisplayType = .section) {
        self.name = name
        self.category = category
        self.tabType = tabType
        self.view = AnyView(view)
        self.displayType = displayType
    }
}
