import SwiftUI
import ZenithCoreInterface


public extension View {
    func actionCardStyle(_ style: some ActionCardStyle) -> some View {
        environment(\.actionCardStyle, style)
    }
}

public struct ContentAActionCardStyle: @preconcurrency ActionCardStyle, BaseThemeDependencies {
    public var id = String(describing: Self.self)
    
    @Dependency(\.themeConfigurator) public var themeConfigurator: any ThemeConfiguratorProtocol
    
    public init() {}
    
    @MainActor
    public func makeBody(configuration: Configuration) -> some View {
        BaseActionCard(configuration: configuration)
            .foregroundColor(colors.contentA)
    }
}

public struct ContentBActionCardStyle: @preconcurrency ActionCardStyle, BaseThemeDependencies {
    public var id = String(describing: Self.self)
    
    @Dependency(\.themeConfigurator) public var themeConfigurator: any ThemeConfiguratorProtocol
    
    public init() {}
    
    @MainActor
    public func makeBody(configuration: Configuration) -> some View {
        BaseActionCard(configuration: configuration)
            .foregroundColor(colors.contentB)
    }
}

public extension ActionCardStyle where Self == ContentAActionCardStyle {
    static func contentA() -> Self { .init() }
}

public extension ActionCardStyle where Self == ContentBActionCardStyle {
    static func contentB() -> Self { .init() }
}

public enum ActionCardStyleCase: CaseIterable, Identifiable {
    case contentA
    case contentB
    
    public var id: Self { self }
    
    public func style() -> AnyActionCardStyle {
        switch self {
        case .contentA:
            .init(.contentA())
        case .contentB:
            .init(.contentB())
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
        Card(alignment: .center, type: .fill, action: {
            configuration.action()
        }) {
            Stack(arrangement: .vertical(alignment: .leading)) {
                HStack(alignment: .top) {
                    Text(configuration.title)
                        .textStyle(.mediumBold(.contentA))
                    Spacer()
                    Button {
                        configuration.action()
                    } label: {
                        DynamicImage(.arrowRight)
                            .dynamicImageStyle(.medium(.contentA))
                    }
                    .buttonStyle(.highlightA())
                }
                Text(configuration.description)
                    .textStyle(.small(.contentA))
                ScrollView(.horizontal) {
                    HStack {
                        ForEach(configuration.tags, id: \.self) {
                            Tag($0)
                                .tagStyle(.small(.default))
                        }
                    }
                }.scrollIndicators(.hidden)
            }
        }
    }
}
