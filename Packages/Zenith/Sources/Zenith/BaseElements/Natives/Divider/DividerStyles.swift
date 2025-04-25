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

public struct ContentADividerStyle: @preconcurrency DividerStyle, BaseThemeDependencies {
    public var id = String(describing: Self.self)
    
    @Dependency(\.themeConfigurator) public var themeConfigurator: any ThemeConfiguratorProtocol
    
    @MainActor
    public func makeBody(configuration: Configuration) -> some View {
        configuration
            .content
            .overlay(colors.contentA)
    }
}

public struct ContentBDividerStyle: @preconcurrency DividerStyle, BaseThemeDependencies {
    public var id = String(describing: Self.self)
    
    @Dependency(\.themeConfigurator) public var themeConfigurator: any ThemeConfiguratorProtocol
    
    @MainActor
    public func makeBody(configuration: Configuration) -> some View {
        configuration
            .content
            .overlay(colors.contentB)
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

public extension DividerStyle where Self == ContentADividerStyle {
    static func contentA() -> Self { ContentADividerStyle() }
}

public extension DividerStyle where Self == ContentBDividerStyle {
    static func contentB() -> Self { ContentBDividerStyle() }
}

public extension DividerStyle where Self == HighlightADividerStyle {
    static func highlightA() -> Self { HighlightADividerStyle() }
}

public enum DividerStyleCase: CaseIterable, Identifiable {
    case contentA
    case contentB
    case highlightA
    
    public var id: Self { self }
    
    public func style() -> AnyDividerStyle {
        switch self {
        case .contentA:
            .init(.contentA())
        case .contentB:
            .init(.contentB())
        case .highlightA:
            .init(.highlightA())
        }
    }
}
