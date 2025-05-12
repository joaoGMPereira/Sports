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
            elementView: .element(title: "BUTTON", ButtonSample())
        ),
        ElementType(
            name: "Text",
            category: .native,
            tabType: .baseElements,
            elementView: .element(title: "TEXT", TextSample())
        ),
        ElementType(
            name: "Divider",
            category: .native,
            tabType: .baseElements,
            elementView: .element(title: "DIVIDER", DividerSample())
        ),
        ElementType(
            name: "Toggle",
            category: .native,
            tabType: .baseElements,
            elementView: .element(title: "TOGGLE", ToggleSample())
        ),
        ElementType(
            name: "TextField",
            category: .native,
            tabType: .baseElements,
            elementView: .element(title: "TEXTFIELD", TextFieldSample())
        ),
        // Base Elements - Customs
        ElementType(
            name: "Dynamic Image",
            category: .custom,
            tabType: .baseElements,
            elementView: .element(title: "DYNAMIC IMAGE", DynamicImageSample())
        ),
        ElementType(
            name: "Tag",
            category: .custom,
            tabType: .baseElements,
            elementView: .element(title: "TAG", TagSample())
        ),
        ElementType(
            name: "RadioButton",
            category: .custom,
            tabType: .baseElements,
            elementView: .element(title: "RADIOBUTTON", RadioButtonSample())
        ),
        ElementType(
            name: "CheckBox",
            category: .custom,
            tabType: .baseElements,
            elementView: .element(title: "CHECKBOX", CheckBoxSample())
        ),
        ElementType(
            name: "IndicatorSelector",
            category: .custom,
            tabType: .components,
            elementView: .element(title: "SELECTOR", IndicatorSelectorSample())
        ),
        ElementType(
            name: "Card",
            category: .custom,
            tabType: .components,
            elementView: .element(title: "CARD", CardSample())
        ),
        ElementType(
            name: "DetailedListItem",
            category: .custom,
            tabType: .components,
            elementView: .element(title: "DETAILEDLISTITEM", type: .pushed, DetailedListItemSample())
        ),
        ElementType(
            name: "HeaderTitle",
            category: .custom,
            tabType: .components,
            elementView: .element(title: "HEADERTITLE", HeaderTitleSample())
        ),
        ElementType(
            name: "Blur",
            category: .custom,
            tabType: .baseElements,
            elementView: .element(title: "BLUR", type: .pushed, BlurSample())
        ),
        ElementType(
            name: "CircularProgress",
            category: .custom,
            tabType: .components,
            elementView: .element(title: "CIRCULARPROGRESS", CircularProgressSample())
        ),
        ElementType(
            name: "ListItem",
            category: .custom,
            tabType: .components,
            elementView: .element(title: "LISTITEM", ListItemSample())
        ),
        // Templates
        ElementType(
            name: "StepsTemplate",
            category: .template,
            tabType: .templates,
            elementView: .element(title: "STEPS TEMPLATE", StepsTemplateSample())
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
        case .element(let title, let type, let view):
            // Usa a nova BaseSampleView
            let sampleViewType: SampleViewType = type == .section ? .section : .pushed
            BaseSampleView(
                title: title,
                viewType: sampleViewType
            ) {
                view
            }
        }
    }
    
    func section(_ view: AnyView) -> some View {
        Section {
            view
        }
    }
}
