import Dependencies
import SwiftUI
import ZenithCoreInterface

public struct CheckBox: View {
    @Environment(\.checkBoxStyle) private var style
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

