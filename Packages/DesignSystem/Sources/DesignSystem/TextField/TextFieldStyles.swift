import SwiftUI

public struct DSRoundedBorderTextFieldStyle: TextFieldStyle {
    var isEnabled: Bool
    
    public init(isEnabled: Bool = true) {
        self.isEnabled = isEnabled
    }
    
    public func _body(configuration: TextField<_Label>) -> some View {
        configuration
            .textFieldStyle(RoundedBorderTextFieldStyle())
            .foregroundColor(isEnabled ? Color.primary : Color.gray)
            .disabled(!isEnabled)
            
    }
}
