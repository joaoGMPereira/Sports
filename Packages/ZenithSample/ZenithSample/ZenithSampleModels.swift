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

enum ElementView {
    case inline(AnyView)
    case navigation(title: String, AnyView)
    case section(AnyView)
    
    static func inline<V: View>(_ view: V) -> ElementView {
        ElementView.inline(AnyView(view))
    }
    
    static func navigation<V: View>(_ title: String, _ view: V) -> ElementView {
        ElementView.navigation(title: title, AnyView(view))
    }
    
    static func section<V: View>(_ view: V) -> ElementView {
        ElementView.section(AnyView(view))
    }
}

struct ElementType: Identifiable {
    var id = UUID()
    var name: String
    var category: ElementCategory
    var tabType: TabType
    var elementView: ElementView
    
    init(name: String, category: ElementCategory, tabType: TabType, elementView: ElementView) {
        self.name = name
        self.category = category
        self.tabType = tabType
        self.elementView = elementView
    }
}
