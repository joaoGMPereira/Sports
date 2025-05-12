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
            category: .native,
            tabType: .baseElements,
            elementView: .element(title: "BUTTON", ButtonSample())
        ),
        ElementType(
            category: .native,
            tabType: .baseElements,
            elementView: .element(title: "TEXT", TextSample())
        ),
        ElementType(
            category: .native,
            tabType: .baseElements,
            elementView: .element(title: "DIVIDER", DividerSample())
        ),
        ElementType(
            category: .native,
            tabType: .baseElements,
            elementView: .element(title: "TOGGLE", ToggleSample())
        ),
        ElementType(
            category: .native,
            tabType: .baseElements,
            elementView: .element(title: "TEXTFIELD", TextFieldSample())
        ),
        // Base Elements - Customs
        ElementType(
            category: .custom,
            tabType: .baseElements,
            elementView: .element(title: "DYNAMIC IMAGE", DynamicImageSample())
        ),
        ElementType(
            category: .custom,
            tabType: .baseElements,
            elementView: .element(title: "TAG", TagSample())
        ),
        ElementType(
            category: .custom,
            tabType: .baseElements,
            elementView: .element(title: "RADIOBUTTON", RadioButtonSample())
        ),
        ElementType(
            category: .custom,
            tabType: .baseElements,
            elementView: .element(title: "CHECKBOX", CheckBoxSample())
        ),
        ElementType(
            category: .custom,
            tabType: .baseElements,
            elementView: .element(title: "BLUR", type: .pushed, BlurSample())
        ),
        // Components - Customs
        ElementType(
            category: .custom,
            tabType: .components,
            elementView: .element(title: "SELECTOR", IndicatorSelectorSample())
        ),
        ElementType(
            category: .custom,
            tabType: .components,
            elementView: .element(title: "CARD", CardSample())
        ),
        ElementType(
            category: .custom,
            tabType: .components,
            elementView: .element(title: "DETAILEDLISTITEM", type: .pushed, DetailedListItemSample())
        ),
        ElementType(
            category: .custom,
            tabType: .components,
            elementView: .element(title: "HEADERTITLE", HeaderTitleSample())
        ),
        ElementType(
            category: .custom,
            tabType: .components,
            elementView: .element(title: "CIRCULARPROGRESS", CircularProgressSample())
        ),
        ElementType(
            category: .custom,
            tabType: .components,
            elementView: .element(title: "LISTITEM", ListItemSample())
        ),
        ElementType(
            category: .custom,
            tabType: .components,
            elementView: .element(title: "FLOATING CARD", type: .pushed, FloatingCardExample())
        ),
        // Templates
        ElementType(
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
