import SwiftUI
import ZenithCoreInterface

public extension View {
    func cardStyle(_ style: some CardStyle) -> some View {
        environment(\.cardStyle, style)
    }
}

public struct FillCardStyle: @preconcurrency CardStyle, BaseThemeDependencies {
    public var id = String(describing: Self.self)
    
    @Dependency(\.themeConfigurator) public var themeConfigurator: any ThemeConfiguratorProtocol
    
    public init() {}
    
    @MainActor
    public func makeBody(configuration: Configuration) -> some View {
        Group {
            if configuration.title.isEmpty {
                EmptyView()
            } else {
                BaseCard(
                    alignment: configuration.arrangement.alignment(),
                    type: .fill,
                    action: configuration.action
                ) {
                    Stack(arrangement: configuration.arrangement.arrangement()) {
                        DynamicImage(configuration.image)
                            .dynamicImageStyle(.small(.highlightA))
                            .padding(themeConfigurator.theme.spacings.small)
                            .background(
                                Circle()
                                    .fill(colors.backgroundTertiary) // Cor de fundo do círculo
                            )
                            .clipShape(Circle())
                        Text(configuration.title)
                            .textStyle(.medium(.textPrimary))
                    }
                }
            }
        }
    }
}

public struct BorderedStyle: @preconcurrency CardStyle, BaseThemeDependencies {
    public var id = String(describing: Self.self)
    
    @Dependency(\.themeConfigurator) public var themeConfigurator: any ThemeConfiguratorProtocol
    
    public init() {}
    
    @MainActor
    public func makeBody(configuration: Configuration) -> some View {
        Group {
            if configuration.title.isEmpty {
                EmptyView()
            } else {
                BaseCard(
                    alignment: configuration.arrangement.alignment(),
                    type: .bordered,
                    action: configuration.action
                ) {
                    Stack(arrangement: configuration.arrangement.arrangement()) {
                        DynamicImage(configuration.image)
                            .dynamicImageStyle(.medium(.primary))
                        Text(configuration.title)
                            .textStyle(.small(.textPrimary))
                    }
                    .frame(maxHeight:.infinity)
                }
                .background {
                    RoundedRectangle(cornerRadius: 24)
                        .stroke(colors.textPrimary, lineWidth: 1)
                }
                
            }
        }
    }
}

public extension CardStyle where Self == FillCardStyle {
    static func fill() -> Self { .init() }
}

public extension CardStyle where Self == BorderedStyle {
    static func bordered() -> Self { .init() }
}

public enum CardStyleCase: CaseIterable, Identifiable {
    case fill
    case bordered
    
    public var id: Self { self }
    
    public func style() -> AnyCardStyle {
        switch self {
        case .fill:
            .init(.fill())
        case .bordered:
            .init(.bordered())
        }
    }
}



public struct BaseCard<Content: View>: View, @preconcurrency BaseThemeDependencies {
    @Dependency(\.themeConfigurator) public var themeConfigurator: any ThemeConfiguratorProtocol
    @GestureState private var isPressed = false
    let alignment: Alignment
    let type: CardType
    let content: Content
    let action: () -> Void
    
    public init(
        alignment: Alignment,
        type: CardType,
        action: @escaping () -> Void,
        @ViewBuilder content: () -> Content
    ) {
        self.alignment = alignment
        self.type = type
        self.action = action
        self.content = content()
    }
    
    public var body: some View {
        Button(action: {
            action()
        }) {
            content
                .padding(themeConfigurator.theme.spacings.medium)
                .frame(maxWidth: .infinity, alignment: alignment)
        }
        .buttonStyle(.cardAppearance(type))
    }
}

public enum CardType: String, CaseIterable, Decodable, Identifiable {
    public var id: String {
        rawValue
    }
    
    case fill, bordered
}
