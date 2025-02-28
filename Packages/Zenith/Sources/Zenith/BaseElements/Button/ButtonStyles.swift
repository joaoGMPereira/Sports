import SwiftUI
import ZenithCoreInterface

public struct PrimaryButtonStyle: ButtonStyle, @preconcurrency BaseThemeDependencies {
    @Dependency(\.themeConfigurator) public var themeConfigurator
    
    public func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(fonts.small.font)
            .padding(spacings.medium)
            .background(
                RoundedRectangle(cornerRadius: .infinity)
                    .stroke(colors.textPrimary, lineWidth: 1)
            )
            .foregroundColor(colors.textPrimary)
    }
}

public extension ButtonStyle where Self == PrimaryButtonStyle {
    static var primary: Self { Self() }
}

public struct SecondaryButtonStyle: ButtonStyle, @preconcurrency BaseThemeDependencies {
    @Dependency(\.themeConfigurator) public var themeConfigurator
    
    public func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(fonts.small.font)
            .padding(spacings.medium)
            .background(
                RoundedRectangle(cornerRadius: .infinity)
                    .stroke(colors.primary, lineWidth: 1)
            )
            .foregroundColor(colors.primary)
    }
}

public extension ButtonStyle where Self == SecondaryButtonStyle {
    static var secondary: Self { Self() }
}


public enum ButtonStyles: String, Decodable, Sendable, Identifiable, CaseIterable {
    public var id: String {
        rawValue
    }
    
    case primary, secondary
    
    public var style: any ButtonStyle {
        switch self {
        case .primary:
            return PrimaryButtonStyle()
        case .secondary:
            return SecondaryButtonStyle()
        }
    }
}
