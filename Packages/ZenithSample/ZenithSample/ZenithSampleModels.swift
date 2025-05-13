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

enum ElementViewType {
    case section
    case pushed
}

enum ElementView {
    case element(_ title: String, type: ElementViewType, overrideList: Bool, AnyView)
    
    static func element<V: View>(title: String, type: ElementViewType = .pushed, overrideList: Bool = true, _ view: V) -> ElementView {
        ElementView.element(title, type: type, overrideList: overrideList, AnyView(view))
    }
}

struct ElementType: Identifiable {
    var id = UUID()
    var category: ElementCategory
    var tabType: TabType
    var elementView: ElementView
    
    init(category: ElementCategory, tabType: TabType, elementView: ElementView) {
        self.category = category
        self.tabType = tabType
        self.elementView = elementView
    }
}
