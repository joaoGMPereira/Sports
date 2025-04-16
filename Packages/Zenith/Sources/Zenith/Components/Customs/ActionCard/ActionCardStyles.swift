import SwiftUI
import ZenithCoreInterface


public extension View {
    func actionCardStyle(_ style: some ActionCardStyle) -> some View {
        environment(\.actionCardStyle, style)
    }
}

public struct PrimaryActionCardStyle: @preconcurrency ActionCardStyle, BaseThemeDependencies {
    public var id = String(describing: Self.self)
    
    @Dependency(\.themeConfigurator) public var themeConfigurator: any ThemeConfiguratorProtocol
    
    public init() {}
    
    @MainActor
    public func makeBody(configuration: Configuration) -> some View {
        BaseActionCard(configuration: configuration)
            .foregroundColor(colors.textPrimary)
    }
}

public struct SecondaryActionCardStyle: @preconcurrency ActionCardStyle, BaseThemeDependencies {
    public var id = String(describing: Self.self)
    
    @Dependency(\.themeConfigurator) public var themeConfigurator: any ThemeConfiguratorProtocol
    
    public init() {}
    
    @MainActor
    public func makeBody(configuration: Configuration) -> some View {
        BaseActionCard(configuration: configuration)
            .foregroundColor(colors.textSecondary)
    }
}

public extension ActionCardStyle where Self == PrimaryActionCardStyle {
    static func primary() -> Self { .init() }
}

public extension ActionCardStyle where Self == SecondaryActionCardStyle {
    static func secondary() -> Self { .init() }
}

public enum ActionCardStyleCase: CaseIterable, Identifiable {
    case primary
    case secondary
    
    public var id: Self { self }
    
    public func style() -> AnyActionCardStyle {
        switch self {
        case .primary:
                .init(.primary())
        case .secondary:
                .init(.secondary())
        }
    }
}

private struct BaseActionCard: View, @preconcurrency BaseThemeDependencies {
    @Dependency(\.themeConfigurator) public var themeConfigurator: any ThemeConfiguratorProtocol
    
    let configuration: ActionCardStyleConfiguration
    
    init(configuration: ActionCardStyleConfiguration) {
        self.configuration = configuration
    }
    
    var body: some View {
        BaseCard(alignment: .center, type: .fill, action: {
            configuration.action()
        }) {
            Stack(arrangement: .vertical(alignment: .leading)) {
                HStack(alignment: .top) {
                    Text(configuration.title)
                        .textStyle(.mediumBold(.textPrimary))
                    Spacer()
                    Button {
                        configuration.action()
                    } label: {
                        DynamicImage(.arrowRight)
                            .dynamicImageStyle(.medium(.primary))
                    }
                    .buttonStyle(.highlightA())
                }
                Text(configuration.description)
                    .textStyle(.small(.textPrimary))
                ScrollView(.horizontal) {
                    HStack {
                        ForEach(configuration.tags, id: \.self) {
                            Tag($0)
                                .tagStyle(.small(.secondary))
                        }
                    }
                }.scrollIndicators(.hidden)
            }
        }
    }
}
