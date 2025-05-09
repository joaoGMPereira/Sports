import SwiftUI
import ZenithCoreInterface


public extension View {
    func listitemStyle(_ style: some ListItemStyle) -> some View {
        environment(\.listitemStyle, style)
    }
}

public struct ContentAListItemStyle: @preconcurrency ListItemStyle, BaseThemeDependencies {
    public var id = String(describing: Self.self)
    
    @Dependency(\.themeConfigurator) public var themeConfigurator: any ThemeConfiguratorProtocol
    
    public init() {}
    
    @MainActor
    public func makeBody(configuration: Configuration) -> some View {
        BaseListItem(configuration: configuration)
            .foregroundColor(colors.contentA)
    }
}

public struct ContentBListItemStyle: @preconcurrency ListItemStyle, BaseThemeDependencies {
    public var id = String(describing: Self.self)
    
    @Dependency(\.themeConfigurator) public var themeConfigurator: any ThemeConfiguratorProtocol
    
    public init() {}
    
    @MainActor
    public func makeBody(configuration: Configuration) -> some View {
        BaseListItem(configuration: configuration)
            .foregroundColor(colors.contentB)
    }
}

public extension ListItemStyle where Self == ContentAListItemStyle {
    static func contentA() -> Self { .init() }
}

public extension ListItemStyle where Self == ContentBListItemStyle {
    static func contentB() -> Self { .init() }
}

public enum ListItemStyleCase: CaseIterable, Identifiable {
    case contentA
    case contentB
    
    public var id: Self { self }
    
    public func style() -> AnyListItemStyle {
        switch self {
        case .contentA:
            .init(.contentA())
        case .contentB:
            .init(.contentB())
        }
    }
}

private struct BaseListItem: View, @preconcurrency BaseThemeDependencies {
    @Dependency(\.themeConfigurator) public var themeConfigurator: any ThemeConfiguratorProtocol
    
    let configuration: ListItemStyleConfiguration
    
    init(configuration: ListItemStyleConfiguration) {
        self.configuration = configuration
    }
    
    var body: some View {
        Text(configuration.text)
            .font(fonts.small)
    }
}
