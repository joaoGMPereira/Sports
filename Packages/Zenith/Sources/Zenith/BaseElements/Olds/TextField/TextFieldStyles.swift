import SwiftUI

// MARK: - Disabled Appearance Modificador

struct DisabledAppearanceModifier: ViewModifier {
    var isEnabled: Bool

    func body(content: Content) -> some View {
        content
            .foregroundColor(isEnabled ? Color.primary : Color.gray)
            .disabled(!isEnabled)
    }
}

// MARK: - DSRoundedBorderTextFieldStyle

public struct DSRoundedBorderTextFieldStyle: TextFieldStyle {
    var isEnabled: Bool

    public init(isEnabled: Bool = true) {
        self.isEnabled = isEnabled
    }

    public func _body(configuration: TextField<_Label>) -> some View {
        configuration
            .textFieldStyle(RoundedBorderTextFieldStyle())
            .modifier(DisabledAppearanceModifier(isEnabled: isEnabled))
    }
}

// MARK: - DSStateTextFieldStyle

public struct DSStateTextFieldStyle: TextFieldStyle {
    var isEnabled: Bool

    public init(isEnabled: Bool = true) {
        self.isEnabled = isEnabled
    }

    public func _body(configuration: TextField<_Label>) -> some View {
        configuration
            .modifier(DisabledAppearanceModifier(isEnabled: isEnabled))
    }
}
