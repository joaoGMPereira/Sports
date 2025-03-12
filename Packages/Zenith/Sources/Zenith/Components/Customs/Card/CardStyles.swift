import SwiftUI
import ZenithCoreInterface

public extension View {
    func cardStyle(_ style: some CardStyle) -> some View {
        environment(\.cardStyle, style)
    }
}

public struct DefaultCardStyle: @preconcurrency CardStyle, BaseThemeDependencies {
    public var id = String(describing: Self.self)
    
    @Dependency(\.themeConfigurator) public var themeConfigurator: any ThemeConfiguratorProtocol
    
    public init() {}
    
    @MainActor
    public func makeBody(configuration: Configuration) -> some View {
        BaseCard(alignment: configuration.arrangement.alignment()) {
            Stack(arrangement: configuration.arrangement.style()) {
                DynamicImage(configuration.image)
                    .dynamicImageStyle(.small(.tertiary))
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
                Stack(arrangement: configuration.arrangement.style()) {
                    DynamicImage(configuration.image)
                        .dynamicImageStyle(.medium(.primary))
                    Text(configuration.title)
                        .font(fonts.small.font)
                        .textStyle(.mediumBold(.textPrimary))
                }
                .padding(themeConfigurator.theme.spacings.medium)
                .frame(maxWidth: .infinity, alignment: configuration.arrangement.alignment())
                .background(
                    RoundedRectangle(cornerRadius: themeConfigurator.theme.constants.smallCornerRadius)
                        .stroke(colors.textPrimary, lineWidth: 1)
                )
            }
        }
    }
}

public extension CardStyle where Self == DefaultCardStyle {
    static func `default`() -> Self { .init() }
}

public extension CardStyle where Self == BorderedStyle {
    static func bordered() -> Self { .init() }
}

public enum CardStyleCase: CaseIterable, Identifiable {
    case `default`
    case bordered
    
    public var id: Self { self }
    
    public func style() -> AnyCardStyle {
        switch self {
        case .default:
            .init(.default())
        case .bordered:
                .init(.bordered())
        }
    }
}

private struct BaseCard<Content: View>: View, @preconcurrency BaseThemeDependencies {
    @Dependency(\.themeConfigurator) public var themeConfigurator: any ThemeConfiguratorProtocol

    let alignment: Alignment
    let content: Content
    
    init(alignment: Alignment, @ViewBuilder content: () -> Content) {
        self.alignment = alignment
        self.content = content()
    }
    
    var body: some View {
        content
            .padding(themeConfigurator.theme.spacings.medium)
            .frame(maxWidth: .infinity, alignment: alignment)
            .background(
                colors.backgroundSecondary
                    .cornerRadius(themeConfigurator.theme.constants.smallCornerRadius)
            )
    }
}
