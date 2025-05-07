import SwiftUI
import Zenith
import SFSafeSymbols
import ZenithCoreInterface
import SwiftUIIntrospect

struct ZenithSampleView: View, @preconcurrency BaseThemeDependencies {
    @Dependency(\.themeConfigurator) var themeConfigurator

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

    struct ElementType: Identifiable {
        var id = UUID()
        var name: String
        var category: ElementCategory
        var tabType: TabType
        var view: AnyView

        init<V: View>(name: String, category: ElementCategory, tabType: TabType, view: V) {
            self.name = name
            self.category = category
            self.tabType = tabType
            self.view = AnyView(view)
        }
    }

    // MARK: - State Properties

    @State private var selectedTab: TabType = .baseElements
    @State private var selectedCategory: ElementCategory = .native

    // MARK: - Element Definitions

    private var elementTypes: [ElementType] = [
        // Base Elements - Natives
        ElementType(
            name: "Button",
            category: .native,
            tabType: .baseElements,
            view: ButtonSample()
        ),
        ElementType(
            name: "Text",
            category: .native,
            tabType: .baseElements,
            view: TextSample()
        ),
        ElementType(
            name: "Divider",
            category: .native,
            tabType: .baseElements,
            view: DividerSample()
        ),
        ElementType(
            name: "Toggle",
            category: .native,
            tabType: .baseElements,
            view: ToggleSample()
        ),
        ElementType(
            name: "TextField",
            category: .native,
            tabType: .baseElements,
            view: TextFieldSample()
        ),
        // Base Elements - Customs
        ElementType(
            name: "Dynamic Image",
            category: .custom,
            tabType: .baseElements,
            view: DynamicImageSample()
        ),
        ElementType(
            name: "Tag",
            category: .custom,
            tabType: .baseElements,
            view: TagSample()
        ),
        ElementType(
            name: "RadioButton",
            category: .custom,
            tabType: .baseElements,
            view: RadioButtonSample()
        ),
        ElementType(
            name: "CheckBox",
            category: .custom,
            tabType: .baseElements,
            view: CheckBoxSample()
                
        ),
        ElementType(
            name: "IndicatorSelector",
            category: .custom,
            tabType: .components,
            view: IndicatorSelectorSample()
        ),
        ElementType(
            name: "Card",
            category: .custom,
            tabType: .components,
            view: CardSample()
        ),
        ElementType(
            name: "ListItem",
            category: .custom,
            tabType: .components,
            view: ListItemSample()
        ),
        ElementType(
            name: "HeaderTitle",
            category: .custom,
            tabType: .components,
            view: HeaderTitleSample()
        ),
        ElementType(
            name: "Blur",
            category: .custom,
            tabType: .baseElements,
            view: BlurSample()
        ),
        // Templates
        ElementType(
            name: "StepsTemplate",
            category: .template,
            tabType: .templates,
            view: StepsTemplateSample()
        )
    ]

    // MARK: - Filtered Elements

    private func filteredElements() -> [ElementType] {
        return elementTypes.filter {
            $0.tabType == selectedTab &&
            $0.category == selectedCategory
        }
    }

    // MARK: - Body

    var body: some View {
        TabView(selection: $selectedTab) {
            ForEach(TabType.allCases) { tabType in
                tabContent(for: tabType)
                    .tabItem {
                        Label(tabType.rawValue, systemSymbol: tabType.icon)
                    }
                    .tag(tabType)
            }
        }
        .accentColor(colors.highlightA)
        .onChange(of: selectedTab) {
            if selectedTab != .baseElements {
                selectedCategory = selectedTab.categories.first ?? .native
            }
        }
    }

    // MARK: - Tab Content

    private func tabContent(for tabType: TabType) -> some View {
        NavigationStack {
            PrincipalToolbarView.start(tabType.rawValue) {
                List {
                    Section {
                        categoryPicker(for: tabType)
                            .listRowBackground(Color.clear)
                            .listRowSeparator(.hidden)
                    }
                    ForEach(filteredElements()) { element in
                        element.view
                            .listRowBackground(Color.clear)
                    }
                    
                    if filteredElements().isEmpty {
                        Text("No \(selectedCategory.rawValue.lowercased()) elements available.")
                            .font(fonts.medium)
                            .foregroundColor(colors.contentA)
                            .listRowBackground(Color.clear)
                    }
                }
                .listRowSeparator(.hidden)
                .listSectionSeparator(.hidden)
            }
        }
    }

    // MARK: - Category Picker

    private func categoryPicker(for tabType: TabType) -> some View {
        Group {
                Picker("Element Category", selection: $selectedCategory) {
                    ForEach(tabType.categories) { category in
                        Text(category.rawValue).font(fonts.mediumBold).tag(category)
                    }
                }
                .pickerStyle(SegmentedPickerStyle())
                .introspect(.picker(style: .segmented), on: .iOS(.v17, .v18)) {
                    $0.backgroundColor = UIColor.clear
                    $0.layer.borderColor = colors.highlightA.uiColor().cgColor
                    $0.selectedSegmentTintColor = colors.highlightA.uiColor()
                    $0.layer.borderWidth = 1
                    
                    let titleTextAttributes = [
                        NSAttributedString.Key.foregroundColor: colors.contentA.uiColor(),
                        NSAttributedString.Key.font: UIFont.systemFont(ofSize: 14, weight: .bold)
                    ]
                    $0.setTitleTextAttributes(
                        titleTextAttributes,
                        for:.normal
                    )
                    
                    let titleTextAttributesSelected = [
                        NSAttributedString.Key.foregroundColor: colors.contentC.uiColor(),
                        NSAttributedString.Key.font: UIFont.systemFont(ofSize: 14, weight: .bold)
                    ]
                    $0.setTitleTextAttributes(
                        titleTextAttributesSelected,
                        for:.selected
                    )
            }
        }
    }
}

// MARK: - Preview
struct ZenithSampleView_Previews: PreviewProvider {
    static var previews: some View {
        ZenithSampleView()
    }
}
