import SwiftUI
import ZenithCoreInterface

public extension View {
    func dynamicImageStyle(_ style: some DynamicImageStyle) -> some View {
        environment(\.dynamicImageStyle, style)
    }
}

public struct SmallDynamicImageStyle: @preconcurrency DynamicImageStyle, BaseThemeDependencies {
    @Dependency(\.themeConfigurator) public var themeConfigurator: any ThemeConfiguratorProtocol
    let color: DynamicImageStyleColor
    
    init(color: DynamicImageStyleColor) {
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
    let color: DynamicImageStyleColor
    
    init(color: DynamicImageStyleColor) {
        self.color = color
    }
    
    @MainActor
    public func makeBody(configuration: Configuration) -> some View {
        BaseDynamicImage(configuration: configuration, color: color)
            .mediumSize()
    }
}

public extension DynamicImageStyle where Self == SmallDynamicImageStyle {
    static func small(_ color: DynamicImageStyleColor) -> Self { .init(color: color)  }
}

public extension DynamicImageStyle where Self == MediumDynamicImageStyle {
    static func medium(_ color: DynamicImageStyleColor) -> Self { .init(color: color)  }
}

public enum DynamicImageStyleColor: CaseIterable, Identifiable, Sendable {
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
    case small
    case medium

    public var id: Self { self }
    
    @MainActor
    public func style(_ color: DynamicImageStyleColor) -> any DynamicImageStyle {
        switch self {
        case .small:
            return SmallDynamicImageStyle(color: color)
        case .medium:
            return MediumDynamicImageStyle(color: color)
        }
    }
}


extension View {
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
    let dynamicImageStyleColor: DynamicImageStyleColor
    
    init(
        configuration: DynamicImageStyleConfiguration,
        color: DynamicImageStyleColor
    ) {
        self.configuration = configuration
        self.dynamicImageStyleColor = color
    }
    
    var body: some View {
        Group {
            if let color = colors.color(by: dynamicImageStyleColor.color) {
                if configuration.type == .async {
                    configuration.asyncImage.foregroundStyle(color)
                } else {
                    configuration.image.foregroundStyle(color)
                }
            } else {
                if configuration.type == .async {
                    configuration.asyncImage
                } else {
                    configuration.image
                }
            }
        }
    }
}
