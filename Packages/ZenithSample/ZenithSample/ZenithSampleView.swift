import SwiftUI
import Zenith
import SFSafeSymbols
import ZenithCoreInterface
import SwiftUIIntrospect

struct ZenithSampleView: View, @preconcurrency BaseThemeDependencies {
    @Dependency(\.themeConfigurator) var themeConfigurator

    // MARK: - State Properties

    @State private var selectedTab: TabType = .baseElements
    @State private var selectedCategory: ElementCategory = .native

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
                    ZenithSampleElements(selectedTab: tabType, selectedCategory: $selectedCategory)
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
                        Text(category.rawValue).font(fonts.largeBold).tag(category)
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
