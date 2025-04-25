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
    let state: DSState
    
    @MainActor
    public func makeBody(configuration: Configuration) -> some View {
        BaseDynamicImage(configuration: configuration, dynamicImageColor: color, state: state)
            .smallSize()
    }
}

public struct MediumDynamicImageStyle: @preconcurrency DynamicImageStyle, BaseThemeDependencies {
    @Dependency(\.themeConfigurator) public var themeConfigurator: any ThemeConfiguratorProtocol
    let color: DynamicImageColor
    let state: DSState
    
    @MainActor
    public func makeBody(configuration: Configuration) -> some View {
        BaseDynamicImage(configuration: configuration, dynamicImageColor: color, state: state)
            .mediumSize()
    }
}

public struct NoneDynamicImageStyle: @preconcurrency DynamicImageStyle, BaseThemeDependencies {
    @Dependency(\.themeConfigurator) public var themeConfigurator: any ThemeConfiguratorProtocol

    @MainActor
    public func makeBody(configuration: Configuration) -> some View {
        BaseDynamicImage(configuration: configuration, dynamicImageColor: .none, state: .enabled)
    }
}

public extension DynamicImageStyle where Self == SmallDynamicImageStyle {
    static func small(_ color: DynamicImageColor, state: DSState = .enabled) -> Self { .init(color: color, state: state)  }
}

public extension DynamicImageStyle where Self == MediumDynamicImageStyle {
    static func medium(_ color: DynamicImageColor, state: DSState = .enabled) -> Self { .init(color: color, state: state)  }
}

public extension DynamicImageStyle where Self == NoneDynamicImageStyle {
    static func none() -> Self { .init()  }
}

public enum DynamicImageColor: CaseIterable, Identifiable, Sendable {
    case contentA
    case contentB
    case highlightA
    case none
    
    public var id: Self { self }
    
    var color: ColorName? {
        switch self {
        case .contentA:
            .contentA
        case .contentB:
            .contentB
        case .highlightA:
            .highlightA
        case .none:
            nil
        }
    }
}

public enum DynamicImageStyleCase: CaseIterable, Identifiable {
    case smallContentA, smallContentB, smallHighlightA, mediumContentA, mediumContentB, mediumHighlightA
    case smallContentADisabled, smallContentBDisabled, smallHighlightADisabled, mediumContentADisabled, mediumContentBDisabled, mediumHighlightADisabled, none
    
    public var id: Self { self }
    
    public func style() -> AnyDynamicImageStyle {
        switch self {
        case .smallContentA:
            .init(.small(.contentA, state: .enabled))
        case .smallContentB:
            .init(.small(.contentB, state: .enabled))
        case .smallHighlightA:
            .init(.small(.highlightA, state: .enabled))
        case .mediumContentA:
            .init(.medium(.contentA, state: .enabled))
        case .mediumContentB:
            .init(.medium(.contentB, state: .enabled))
        case .mediumHighlightA:
            .init(.medium(.highlightA, state: .enabled))
        case .smallContentADisabled:
            .init(.small(.contentA, state: .disabled))
        case .smallContentBDisabled:
            .init(.small(.contentB, state: .disabled))
        case .smallHighlightADisabled:
            .init(.small(.highlightA, state: .disabled))
        case .mediumContentADisabled:
            .init(.medium(.contentA, state: .disabled))
        case .mediumContentBDisabled:
            .init(.medium(.contentB, state: .disabled))
        case .mediumHighlightADisabled:
            .init(.medium(.highlightA, state: .disabled))
        case .none:
            .init(.none())
        }
    }
}

fileprivate extension View {
    func smallSize() -> some View {
        font(.system(size: 16))
        .frame(width: 16, height: 16)
    }
    func mediumSize() -> some View {
        font(.system(size: 24))
        .frame(width: 24, height: 24)
    }
}

private struct BaseDynamicImage: View, @preconcurrency BaseThemeDependencies {
    @Dependency(\.themeConfigurator) public var themeConfigurator: any ThemeConfiguratorProtocol
    let configuration: DynamicImageStyleConfiguration
    let dynamicImageColor: DynamicImageColor
    let state: DSState
    
    var body: some View {
        Group {
            if let dynamicImageColor = dynamicImageColor.color, let color = colors.color(by: dynamicImageColor) {
                let color = state == .enabled ? color : color.opacity(constants.disabledOpacity)
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
