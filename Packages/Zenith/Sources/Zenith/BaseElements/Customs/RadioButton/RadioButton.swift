import Dependencies
import SwiftUI
import ZenithCoreInterface

public struct RadioButton: View {
    @Environment(\.radioButtonStyle) private var style
    let text: String
    @Binding var isSelected: Bool
    @Binding var isDisabled: Bool
    
    public init<V: Hashable & Sendable>(
        tag: V,
        selection: Binding<V?>,
        text: String,
        disabled: Binding<Bool> = .constant(false)
    ) {
        self._isSelected = Binding(
            get: { selection.wrappedValue == tag },
            set: { _ in selection.wrappedValue = tag }
        )
        self.text = text
        self._isDisabled = disabled
    }
    
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
                configuration: RadioButtonStyleConfiguration(
                    isSelected: $isSelected,
                    text: text,
                    isDisabled: $isDisabled
                )
            )
        )
    }
}

public extension RadioButton {
    func isDisabled(_ value: Bool) -> RadioButton {
        var copy = self
        copy._isDisabled = .constant(value)
        return copy
    }
}
