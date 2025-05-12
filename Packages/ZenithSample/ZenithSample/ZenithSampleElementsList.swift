import SwiftUI
import Zenith
import SFSafeSymbols
import ZenithCoreInterface

struct ZenithSampleElementsList: View, @preconcurrency BaseThemeDependencies {
    // MARK: - Properties
    let selectedTab: TabType
    @Binding var selectedCategory: ElementCategory
    
    @Dependency(\.themeConfigurator) var themeConfigurator
    
    init(selectedTab: TabType, selectedCategory: Binding<ElementCategory>) {
        self.selectedTab = selectedTab
        self._selectedCategory = selectedCategory
    }
    
    // MARK: - Element Definitions

    private var elementTypes: [ElementType] = [
        // Base Elements - Natives
        ElementType(
            name: "Button",
            category: .native,
            tabType: .baseElements,
            elementView: .section(ButtonSample())
        ),
        ElementType(
            name: "Text",
            category: .native,
            tabType: .baseElements,
            elementView: .section(TextSample())
        ),
        ElementType(
            name: "Divider",
            category: .native,
            tabType: .baseElements,
            elementView: .section(DividerSample())
        ),
        ElementType(
            name: "Toggle",
            category: .native,
            tabType: .baseElements,
            elementView: .section(ToggleSample())
        ),
        ElementType(
            name: "TextField",
            category: .native,
            tabType: .baseElements,
            elementView: .section(TextFieldSample())
        ),
        // Base Elements - Customs
        ElementType(
            name: "Dynamic Image",
            category: .custom,
            tabType: .baseElements,
            elementView: .section(DynamicImageSample())
        ),
        ElementType(
            name: "Tag",
            category: .custom,
            tabType: .baseElements,
            elementView: .section(TagSample())
        ),
        ElementType(
            name: "RadioButton",
            category: .custom,
            tabType: .baseElements,
            elementView: .section(RadioButtonSample())
        ),
        ElementType(
            name: "CheckBox",
            category: .custom,
            tabType: .baseElements,
            elementView: .section(CheckBoxSample())
        ),
        ElementType(
            name: "IndicatorSelector",
            category: .custom,
            tabType: .components,
            elementView: .section(IndicatorSelectorSample())
        ),
        ElementType(
            name: "Card",
            category: .custom,
            tabType: .components,
            elementView: .section(CardSample())
        ),
        ElementType(
            name: "DetailedListItem",
            category: .custom,
            tabType: .components,
            elementView: .navigation(
                "DetailedListItem",
                DetailedListItemSample()
            )
        ),
        ElementType(
            name: "HeaderTitle",
            category: .custom,
            tabType: .components,
            elementView: .section(HeaderTitleSample())
        ),
        ElementType(
            name: "Blur",
            category: .custom,
            tabType: .baseElements,
            elementView: .navigation(
                "Blur",
                BlurSample()
            )
        ),
        ElementType(
            name: "CircularProgress",
            category: .custom,
            tabType: .components,
            elementView: .section(CircularProgressSample())
        ),
        ElementType(
            name: "ListItem",
            category: .custom,
            tabType: .components,
            elementView: .section(ListItemSample())
        ),
        // Templates
        ElementType(
            name: "StepsTemplate",
            category: .template,
            tabType: .templates,
            elementView: .section(StepsTemplateSample())
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
        // Exibir elementos filtrados com base em seu tipo de exibição
        ForEach(filteredElements()) { element in
            renderElement(element)
        }
        
        if filteredElements().isEmpty {
            Text("No \(selectedCategory.rawValue.lowercased()) elements available.")
                .textStyle(.large(.contentA))
                .listRowBackground(Color.clear)
        }
    }
    
    // MARK: - Element Renderer
    
    @ViewBuilder
    private func renderElement(_ element: ElementType) -> some View {
        switch element.elementView {
        case .inline(let view):
            // Exibe o conteúdo diretamente na lista
            view
                .listRowBackground(colors.backgroundB)
                
        case .navigation(let title, let destinationView):
            // Usa NavigationLink com destination para iOS 17
            HStack {
                Text(element.name.uppercased())
                    .textStyle(.mediumBold(.highlightA))
                    .padding(.top, 2)
                Spacer()
                Image(systemSymbol: .chevronRight)
                    .foregroundColor(colors.contentA)
                    .font(.system(size: 14))
            }
            .background {
                NavigationLink {
                    PushedListView(title) {
                        destinationView
                    }
                } label: {
                    EmptyView()
                }
            }
            .listRowBackground(colors.backgroundB)
            
        case .section(let view):
            section(view)
                .listRowBackground(colors.backgroundB)
        }
    }
    
    func section(_ view: AnyView) -> some View {
        Section {
            view
        }
    }
}
