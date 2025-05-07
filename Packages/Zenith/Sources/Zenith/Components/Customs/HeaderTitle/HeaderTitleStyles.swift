import SwiftUI
import ZenithCoreInterface

public extension View {
    func headerTitleStyle(_ style: some HeaderTitleStyle) -> some View {
        environment(\.headerTitleStyle, style)
    }
}

public struct ContentAHeaderTitleStyle: @preconcurrency HeaderTitleStyle, BaseThemeDependencies {
    public var id = String(describing: Self.self)
    
    @Dependency(\.themeConfigurator) public var themeConfigurator: any ThemeConfiguratorProtocol
    
    public init() {}
    
    @MainActor
    public func makeBody(configuration: Configuration) -> some View {
        BaseHeaderTitle(
            configuration: configuration,
            textColor: .contentA,
            dynamicImageColor: .contentA
        )
    }
}

public struct ContentBHeaderTitleStyle: @preconcurrency HeaderTitleStyle, BaseThemeDependencies {
    public var id = String(describing: Self.self)
    
    @Dependency(\.themeConfigurator) public var themeConfigurator: any ThemeConfiguratorProtocol
    
    public init() {}
    
    @MainActor
    public func makeBody(configuration: Configuration) -> some View {
        BaseHeaderTitle(
            configuration: configuration,
            textColor: .contentC,
            dynamicImageColor: .contentC
        )
    }
}

public extension HeaderTitleStyle where Self == ContentAHeaderTitleStyle {
    static func contentA() -> Self { .init() }
}

public extension HeaderTitleStyle where Self == ContentBHeaderTitleStyle {
    static func contentC() -> Self { .init() }
}

public enum HeaderTitleStyleCase: CaseIterable, Identifiable {
    case contentA
    case contentC
    
    public var id: Self { self }
    
    public func style() -> AnyHeaderTitleStyle {
        switch self {
        case .contentA:
            .init(.contentA())
        case .contentC:
            .init(.contentC())
        }
    }
}

private struct BaseHeaderTitle: View, @preconcurrency BaseThemeDependencies {
    @Dependency(\.themeConfigurator) public var themeConfigurator: any ThemeConfiguratorProtocol
    
    let configuration: HeaderTitleStyleConfiguration
    let textColor: ColorName
    let dynamicImageColor: DynamicImageColor
    
    var body: some View {
        HStack(alignment: .top) {
            Text(configuration.text)
                .textStyle(.mediumBold(textColor))
            Spacer()
            if configuration.image.isNotEmpty {
                Button(
                    action: {
                        configuration.action?()
                    }, label: {
                        DynamicImage(configuration.image)
                            .dynamicImageStyle(.small(dynamicImageColor))
                    }
                )
                .buttonStyle(.backgroundD(shape: .circle))
            }
        }
        .padding(.horizontal, spacings.large)
        .padding(.vertical, spacings.medium)
        .overlay(GeometryReader { geometry in
            Color.clear
                .preference(key: HeaderTitleHeightKey.self, value: geometry.size.height)
        })
    }
}
