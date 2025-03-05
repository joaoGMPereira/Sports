import SwiftUI
import ZenithCoreInterface

public struct AnyButtonStyle: ButtonStyle {
    public let id: UUID = .init()
    
    private let _makeBody: (ButtonStyleConfiguration) -> AnyView
    
    public init<S: ButtonStyle>(_ style: S) {
        _makeBody = { configuration in
            AnyView(style.makeBody(configuration: configuration))
        }
    }
    
    public func makeBody(configuration: ButtonStyleConfiguration) -> some View {
        _makeBody(configuration)
    }
}

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

public enum ButtonStyleCase: String, Decodable, Sendable, Identifiable, CaseIterable {
    public var id: String {
        rawValue
    }
    
    case primary, secondary
    
    @MainActor
    public func style() -> AnyButtonStyle {
        switch self {
        case .primary:
            return .init(.primary)
        case .secondary:
            return .init(.secondary)
        }
    }
}
