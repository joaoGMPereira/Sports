import SwiftUI
import ZenithCore

public struct FillButtonStyle: ButtonStyle {
    var color: Color
    var isEnabled: Bool
    
    public init(color: Color, isEnabled: Bool = true) {
        self.color = color
        self.isEnabled = isEnabled
    }
    
    public func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .frame(maxWidth: .infinity)
            .padding(.vertical, 8)
            .background(configuration.isPressed ? color.opacity(0.8) : color) // Feedback visual ao pressionar
            .foregroundColor(.white)
            .cornerRadius(8)
            .scaleEffect(configuration.isPressed ? 0.95 : 1.0) // Efeito de escala ao pressionar
            .animation(.easeInOut(duration: 0.1), value: configuration.isPressed)
            .opacity(isEnabled ? 1.0 : 0.6)
    }
}

public struct ContentButtonStyle: ButtonStyle {
    var color: Color
    var isEnabled: Bool
    
    public init(color: Color, isEnabled: Bool = true) {
        self.color = color
        self.isEnabled = isEnabled
    }
    
    public func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .background(configuration.isPressed ? color.opacity(0.8) : color) // Feedback visual ao pressionar
            .foregroundColor(.white)
            .cornerRadius(8)
            .scaleEffect(configuration.isPressed ? 0.95 : 1.0) // Efeito de escala ao pressionar
            .animation(.easeInOut(duration: 0.1), value: configuration.isPressed)
            .opacity(isEnabled ? 1.0 : 0.6)
    }
}

public struct DSBorderedButtonStyle: ButtonStyle {
    var color: Color
    var isEnabled: Bool
    
    public init(color: Color, isEnabled: Bool = true) {
        self.color = color
        self.isEnabled = isEnabled
    }
    
    public func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .background(.clear) // Feedback visual ao pressionar
            .foregroundColor(configuration.isPressed ? color.opacity(0.8) : color)
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(configuration.isPressed ? color.opacity(0.8) : color, lineWidth: 2)
            )
            .cornerRadius(8)
            .scaleEffect(configuration.isPressed ? 0.95 : 1.0) // Efeito de escala ao pressionar
            .animation(.easeInOut(duration: 0.1), value: configuration.isPressed)
            .opacity(isEnabled ? 1.0 : 0.6)
    }
}

public struct WithoutBackgroundPrimaryButtonStyle: ButtonStyle {
    var isEnabled: Bool
    
    public init(isEnabled: Bool = true) {
        self.isEnabled = isEnabled
    }
    
    public func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .frame(maxWidth: .infinity) // Ocupa a largura total disponível
            .padding(.vertical, 8)
            .contentShape(Rectangle())
            .backgroundStyle(.clear) // Feedback visual ao pressionar
            .foregroundColor(configuration.isPressed ? Asset.primary.swiftUIColor.opacity(0.8) : Asset.primary.swiftUIColor)
            .cornerRadius(8)
            .scaleEffect(configuration.isPressed ? 0.95 : 1.0) // Efeito de escala ao pressionar
            .animation(.easeInOut(duration: 0.1), value: configuration.isPressed)
            .opacity(isEnabled ? 1.0 : 0.6)
    }
}
