import SwiftUI
import ZenithCoreInterface


public extension View {
    func decomponentStyle(_ style: some DeComponentStyle) -> some View {
        environment(\.decomponentStyle, style)
    }
}

public struct ContentADeComponentStyle: @preconcurrency DeComponentStyle, BaseThemeDependencies {
    public var id = String(describing: Self.self)
    
    @Dependency(\.themeConfigurator) public var themeConfigurator: any ThemeConfiguratorProtocol
    
    public init() {}
    
    @MainActor
    public func makeBody(configuration: Configuration) -> some View {
        BaseDeComponent(configuration: configuration)
            .foregroundColor(colors.contentA)
    }
}

public struct ContentBDeComponentStyle: @preconcurrency DeComponentStyle, BaseThemeDependencies {
    public var id = String(describing: Self.self)
    
    @Dependency(\.themeConfigurator) public var themeConfigurator: any ThemeConfiguratorProtocol
    
    public init() {}
    
    @MainActor
    public func makeBody(configuration: Configuration) -> some View {
        BaseDeComponent(configuration: configuration)
            .foregroundColor(colors.contentB)
    }
}

public extension DeComponentStyle where Self == ContentADeComponentStyle {
    static func contentA() -> Self { .init() }
}

public extension DeComponentStyle where Self == ContentBDeComponentStyle {
    static func contentB() -> Self { .init() }
}

public enum DeComponentStyleCase: CaseIterable, Identifiable {
    case contentA
    case contentB
    
    public var id: Self { self }
    
    public func style() -> AnyDeComponentStyle {
        switch self {
        case .contentA:
            .init(.contentA())
        case .contentB:
            .init(.contentB())
        }
    }
}

private struct BaseDeComponent: View, @preconcurrency BaseThemeDependencies {
    @Dependency(\.themeConfigurator) public var themeConfigurator: any ThemeConfiguratorProtocol
    
    let configuration: DeComponentStyleConfiguration
    
    init(configuration: DeComponentStyleConfiguration) {
        self.configuration = configuration
    }
    
    var body: some View {
        Text(configuration.text)
            .font(fonts.small)
    }
}
