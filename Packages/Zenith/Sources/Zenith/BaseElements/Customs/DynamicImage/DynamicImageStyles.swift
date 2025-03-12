import SwiftUI
import ZenithCoreInterface

public extension View {
    func dynamicImageStyle(_ style: some DynamicImageStyle) -> some View {
        environment(\.dynamicImageStyle, style)
    }
}

public struct SmallDynamicImageStyle: @preconcurrency DynamicImageStyle, BaseThemeDependencies {
    @Dependency(\.themeConfigurator) public var themeConfigurator: any ThemeConfiguratorProtocol
    let color: DynamicImageColor
    
    init(color: DynamicImageColor) {
        self.color = color
    }
    
    @MainActor
    public func makeBody(configuration: Configuration) -> some View {
        BaseDynamicImage(configuration: configuration, color: color)
            .smallSize()
    }
}

public struct MediumDynamicImageStyle: @preconcurrency DynamicImageStyle, BaseThemeDependencies {
    @Dependency(\.themeConfigurator) public var themeConfigurator: any ThemeConfiguratorProtocol
    let color: DynamicImageColor
    
    init(color: DynamicImageColor) {
        self.color = color
    }
    
    @MainActor
    public func makeBody(configuration: Configuration) -> some View {
        BaseDynamicImage(configuration: configuration, color: color)
            .mediumSize()
    }
}

public extension DynamicImageStyle where Self == SmallDynamicImageStyle {
    static func small(_ color: DynamicImageColor) -> Self { .init(color: color)  }
}

public extension DynamicImageStyle where Self == MediumDynamicImageStyle {
    static func medium(_ color: DynamicImageColor) -> Self { .init(color: color)  }
}

public enum DynamicImageColor: CaseIterable, Identifiable, Sendable {
    case primary
    case secondary
    case tertiary
    
    public var id: Self { self }
    
    var color: ColorName {
        switch self {
        case .primary:
            .textPrimary
        case .secondary:
            .textSecondary
        case .tertiary:
            .primary
        }
    }
}

public enum DynamicImageStyleCase: CaseIterable, Identifiable {
    case smallPrimary
    case smallSecondary
    case smallTertiary
    case mediumPrimary
    case mediumSecondary
    case mediumTertiary
    
    public var id: Self { self }
    
    public func style() -> AnyDynamicImageStyle {
        switch self {
        case .smallPrimary:
            .init(.small(.primary))
        case .smallSecondary:
            .init(.small(.secondary))
        case .smallTertiary:
            .init(.small(.tertiary))
        case .mediumPrimary:
            .init(.medium(.primary))
        case .mediumSecondary:
            .init(.medium(.secondary))
        case .mediumTertiary:
            .init(.medium(.tertiary))
        }
    }
}

fileprivate extension View {
    func smallSize() -> some View {
        frame(width: 16, height: 16)
    }
    func mediumSize() -> some View {
        frame(width: 24, height: 24)
    }
}

private struct BaseDynamicImage: View, @preconcurrency BaseThemeDependencies {
    @Dependency(\.themeConfigurator) public var themeConfigurator: any ThemeConfiguratorProtocol
    let configuration: DynamicImageStyleConfiguration
    let DynamicImageColor: DynamicImageColor
    
    init(
        configuration: DynamicImageStyleConfiguration,
        color: DynamicImageColor
    ) {
        self.configuration = configuration
        self.DynamicImageColor = color
    }
    
    var body: some View {
        Group {
            if let color = colors.color(by: DynamicImageColor.color) {
                if configuration.type == .async {
                    configuration.asyncImage.foregroundStyle(color).scaledToFit()
                } else {
                    configuration.image.foregroundStyle(color).scaledToFit()
                }
            } else {
                if configuration.type == .async {
                    configuration.asyncImage.scaledToFit()
                } else {
                    configuration.image.scaledToFit()
                }
            }
        }
    }
}
