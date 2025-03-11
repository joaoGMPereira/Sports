import SwiftUI
import ZenithCoreInterface


public extension View {
    func checkboxStyle(_ style: some CheckBoxStyle) -> some View {
        environment(\.checkboxStyle, style)
    }
}

public struct PrimaryCheckBoxStyle: @preconcurrency CheckBoxStyle, BaseThemeDependencies {
    public var id = String(describing: Self.self)
    
    @Dependency(\.themeConfigurator) public var themeConfigurator: any ThemeConfiguratorProtocol
    
    public init() {}
    
    @MainActor
    public func makeBody(configuration: Configuration) -> some View {
        BaseCheckBox(configuration: configuration)
            .foregroundColor(colors.textPrimary)
    }
}

public struct SecondaryCheckBoxStyle: @preconcurrency CheckBoxStyle, BaseThemeDependencies {
    public var id = String(describing: Self.self)
    
    @Dependency(\.themeConfigurator) public var themeConfigurator: any ThemeConfiguratorProtocol
    
    public init() {}
    
    @MainActor
    public func makeBody(configuration: Configuration) -> some View {
        BaseCheckBox(configuration: configuration)
            .foregroundColor(colors.textSecondary)
    }
}

public extension CheckBoxStyle where Self == PrimaryCheckBoxStyle {
    static func primary() -> Self { .init() }
}

public extension CheckBoxStyle where Self == SecondaryCheckBoxStyle {
    static func secondary() -> Self { .init() }
}

public enum CheckBoxStyleCase: CaseIterable, Identifiable {
    case primary
    case secondary
    
    public var id: Self { self }
    
    public func style() -> AnyCheckBoxStyle {
        switch self {
        case .primary:
            .init(.primary())
        case .secondary:
            .init(.secondary())
        }
    }
}

private struct BaseCheckBox: View, @preconcurrency BaseThemeDependencies {
    @Dependency(\.themeConfigurator) public var themeConfigurator: any ThemeConfiguratorProtocol
    
    let configuration: CheckBoxStyleConfiguration
    
    init(configuration: CheckBoxStyleConfiguration) {
        self.configuration = configuration
    }
    
    var body: some View {
        Text(configuration.text)
            .font(fonts.small.font)
    }
}
