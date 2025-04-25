import SwiftUI
import ZenithCoreInterface

public extension View {
    func cardStyle(_ style: some BasicCardStyle) -> some View {
        environment(\.cardStyle, style)
    }
}

public struct FillBasicCardStyle: @preconcurrency BasicCardStyle, BaseThemeDependencies {
    public var id = String(describing: Self.self)
    
    @Dependency(\.themeConfigurator) public var themeConfigurator: any ThemeConfiguratorProtocol
    
    public init() {}
    
    @MainActor
    public func makeBody(configuration: Configuration) -> some View {
        Group {
            if configuration.title.isEmpty {
                EmptyView()
            } else {
                CardContent(configuration: configuration) {
                    ImageTextContentView(
                        image: configuration.image,
                        title: configuration.title,
                        layout: configuration.contentLayout
                    )
                }
            }
        }
    }
}

public struct BorderedStyle: @preconcurrency BasicCardStyle, BaseThemeDependencies {
    public var id = String(describing: Self.self)
    
    @Dependency(\.themeConfigurator) public var themeConfigurator: any ThemeConfiguratorProtocol
    
    public init() {}
    
    @MainActor
    public func makeBody(configuration: Configuration) -> some View {
        Group {
            if configuration.title.isEmpty {
                EmptyView()
            } else {
                CardContent(configuration: configuration) {
                    ImageTextContentView(
                        image: configuration.image,
                        title: configuration.title,
                        layout: configuration.contentLayout
                    )
                }
                .background {
                    RoundedRectangle(cornerRadius: 24)
                        .stroke(colors.contentA, lineWidth: 1)
                }
                
            }
        }
    }
}

public extension BasicCardStyle where Self == FillBasicCardStyle {
    static func fill() -> Self { .init() }
}

public extension BasicCardStyle where Self == BorderedStyle {
    static func bordered() -> Self { .init() }
}

public enum BasicCardStyleCase: String, Decodable, CaseIterable, Equatable {
    case fill
    case bordered
    
    public var id: Self { self }
    
    public func style() -> AnyBasicCardStyle {
        switch self {
        case .fill:
            .init(.fill())
        case .bordered:
            .init(.bordered())
        }
    }
}

private struct CardContent<Content: View>: View {
    let configuration: BasicCardStyleConfiguration
    let content: Content
    
    init(
        configuration: BasicCardStyleConfiguration,
        @ViewBuilder content: () -> Content
    ) {
        self.configuration = configuration
        self.content = content()
    }
    var body: some View {
        Card(
            alignment: configuration.arrangement.alignment(),
            type: .fill,
            action: configuration.action
        ) {
            Stack(arrangement: configuration.arrangement.arrangement()) {
                content
            }
            .frame(maxHeight:.infinity)
        }
    }
}


private struct ImageTextContentView: View {
    let image: String
    let title: String
    let layout: CardLayoutCase

    var body: some View {
        Group {
            switch layout {
            case .imageText, .imageSpacerText:
                imageView
                if layout.hasSpacer { Spacer() }
                textView
            case .textImage, .textSpacerImage:
                textView
                if layout.hasSpacer { Spacer() }
                imageView
            }
        }
    }

    private var imageView: some View {
        DynamicImage(image)
            .dynamicImageStyle(.medium(.contentA))
    }

    private var textView: some View {
        Text(title)
            .textStyle(.small(.contentA))
    }
}
