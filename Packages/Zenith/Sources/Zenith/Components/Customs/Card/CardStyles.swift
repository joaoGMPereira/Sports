import SwiftUI
import ZenithCoreInterface


public extension View {
    func cardStyle(_ style: some CardStyle) -> some View {
        environment(\.cardStyle, style)
    }
}

public struct PrimaryCardStyle: @preconcurrency CardStyle, BaseThemeDependencies {
    public var id = String(describing: Self.self)
    
    @Dependency(\.themeConfigurator) public var themeConfigurator: any ThemeConfiguratorProtocol
    
    public init() {}
    
    @MainActor
    public func makeBody(configuration: Configuration) -> some View {
        BaseCard(configuration: configuration)
            .foregroundColor(colors.textPrimary)
    }
}

public struct SecondaryCardStyle: @preconcurrency CardStyle, BaseThemeDependencies {
    public var id = String(describing: Self.self)
    
    @Dependency(\.themeConfigurator) public var themeConfigurator: any ThemeConfiguratorProtocol
    
    public init() {}
    
    @MainActor
    public func makeBody(configuration: Configuration) -> some View {
        BaseCard(configuration: configuration)
            .foregroundColor(colors.textSecondary)
    }
}

public extension CardStyle where Self == PrimaryCardStyle {
    static func primary() -> Self { .init() }
}

public extension CardStyle where Self == SecondaryCardStyle {
    static func secondary() -> Self { .init() }
}

public enum CardStyleCase: CaseIterable, Identifiable {
    case primary
    case secondary
    
    public var id: Self { self }
    
    public func style() -> AnyCardStyle {
        switch self {
        case .primary:
            .init(.primary())
        case .secondary:
            .init(.secondary())
        }
    }
}

private struct BaseCard: View, @preconcurrency BaseThemeDependencies {
    @Dependency(\.themeConfigurator) public var themeConfigurator: any ThemeConfiguratorProtocol
    
    let configuration: CardStyleConfiguration
    
    init(configuration: CardStyleConfiguration) {
        self.configuration = configuration
    }
    
    var body: some View {
        Text(configuration.text)
            .font(fonts.small.font)
    }
}
