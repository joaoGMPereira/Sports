import Dependencies
import SwiftUI
import ZenithCoreInterface

public struct CheckBoxItem: Identifiable {
    let placeholder: String
    public let id: String
    
    public init(placeholder: String, id: String) {
        self.placeholder = placeholder
        self.id = id
    }
}

public struct CheckBoxBundle: View, @preconcurrency BaseThemeDependencies {
    @Dependency(\.themeConfigurator) public var themeConfigurator
    @Binding private var selectedItems: Set<String>
    let items: [CheckBoxItem]
    
    public init(selectedItems: Binding<Set<String>>, items: [CheckBoxItem]) {
        self._selectedItems = selectedItems
        self.items = items
    }
    
    public var body: some View {
        HStack {
            Spacer()
            ForEach(items) { item in
                VStack {
                    if item.placeholder.isNotEmpty {
                        Text(item.placeholder)
                            .textStyle(.small(.contentA))
                            .padding(spacings.extraSmall)
                    }
                    CheckBox(
                        isSelected: Binding(
                            get: { selectedItems.contains(item.id) },
                            set: { isSelected in
                                if isSelected {
                                    selectedItems.insert(item.id)
                                } else {
                                    selectedItems.remove(item.id)
                                }
                            }
                        )
                    )
                }
                Spacer()
            }
        }
    }
}
