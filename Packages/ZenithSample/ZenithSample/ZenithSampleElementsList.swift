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
            name: "DetailedListItem",
            category: .custom,
            tabType: .components,
            view: DetailedListItemSample()
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
            view: EmptyView(),
            displayType: .navigation(
                AnyView(
                    PushedListView("Blur") {
                        BlurSample()
                    }
                )
            )
            
        ),
        ElementType(
            name: "CircularProgress",
            category: .custom,
            tabType: .components,
            view: CircularProgressSample()
        ),
        ElementType(
            name: "ListItem",
            category: .custom,
            tabType: .components,
            view: ListItemSample()
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
        section(element)
        switch element.displayType {
        case .inline:
            // Exibe o conteúdo diretamente na lista
            element.view
                .listRowBackground(colors.backgroundB)
                
        case .navigation(let destinationView):
            // Cria uma navegação para outra tela
            NavigationLink {
                destinationView
            } label: {
                Text(element.name.uppercased())
                    .textStyle(.mediumBold(.highlightA))
                    .padding(.vertical, 2)
            }
            .listRowBackground(colors.backgroundB)
            
        case .section:
            section(element)
        }
    }
    
    
    
    func section(_ element: ElementType) -> some View {
        Section {
            element.view
                .listRowBackground(Color.clear)
        }
    }
}
