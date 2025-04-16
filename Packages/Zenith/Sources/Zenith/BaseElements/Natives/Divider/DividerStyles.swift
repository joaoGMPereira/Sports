import SwiftUI
import ZenithCoreInterface

public extension Divider {
    func dividerStyle(_ style: some DividerStyle) -> some View {
        AnyView(
            style.resolve(
                configuration: DividerStyleConfiguration(
                    content: self
                )
            ).environment(\.dividerStyle, style)
        )
    }
}

public struct PrimaryDividerStyle: @preconcurrency DividerStyle, BaseThemeDependencies {
    public var id = String(describing: Self.self)
    
    @Dependency(\.themeConfigurator) public var themeConfigurator: any ThemeConfiguratorProtocol
    
    @MainActor
    public func makeBody(configuration: Configuration) -> some View {
        configuration
            .content
            .overlay(colors.textPrimary)
    }
}

public struct SecondaryDividerStyle: @preconcurrency DividerStyle, BaseThemeDependencies {
    public var id = String(describing: Self.self)
    
    @Dependency(\.themeConfigurator) public var themeConfigurator: any ThemeConfiguratorProtocol
    
    @MainActor
    public func makeBody(configuration: Configuration) -> some View {
        configuration
            .content
            .overlay(colors.textSecondary)
    }
}

public struct HighlightADividerStyle: @preconcurrency DividerStyle, BaseThemeDependencies {
    public var id = String(describing: Self.self)
    
    @Dependency(\.themeConfigurator) public var themeConfigurator: any ThemeConfiguratorProtocol
    
    @MainActor
    public func makeBody(configuration: Configuration) -> some View {
        configuration
            .content
            .overlay(colors.highlightA)
    }
}

public extension DividerStyle where Self == PrimaryDividerStyle {
    static func primary() -> Self { PrimaryDividerStyle() }
}

public extension DividerStyle where Self == SecondaryDividerStyle {
    static func secondary() -> Self { SecondaryDividerStyle() }
}

public extension DividerStyle where Self == HighlightADividerStyle {
    static func highlightA() -> Self { HighlightADividerStyle() }
}

public enum DividerStyleCase: CaseIterable, Identifiable {
    case primary
    case secondary
    case highlightA
    
    public var id: Self { self }
    
    public func style() -> AnyDividerStyle {
        switch self {
        case .primary:
            .init(.primary())
        case .secondary:
            .init(.secondary())
        case .highlightA:
            .init(.highlightA())
        }
    }
}
