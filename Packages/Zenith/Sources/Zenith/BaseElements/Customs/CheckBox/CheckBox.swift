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

public struct CheckBox: View {
    @Environment(\.checkboxStyle) private var style
    let text: String
    @Binding var isSelected: Bool
    @Binding var isDisabled: Bool
    
    public init(
        isSelected: Binding<Bool>,
        text: String = "",
        disabled: Binding<Bool> = .constant(false)
    ) {
        self._isSelected = isSelected
        self.text = text
        self._isDisabled = disabled
    }
    
    public var body: some View {
        AnyView(
            style.resolve(
                configuration: CheckBoxStyleConfiguration(
                    isSelected: $isSelected,
                    text: text,
                    isDisabled: $isDisabled
                )
            )
        )
    }
}

public extension CheckBox {
    func isDisabled(_ value: Bool) -> CheckBox {
        var copy = self
        copy._isDisabled = .constant(value)
        return copy
    }
}

