import SwiftUI
import ZenithCoreInterface


public extension View {
    func actionCardStyle(_ style: some ListItemStyle) -> some View {
        environment(\.actionCardStyle, style)
    }
}

public struct DefaultListItemStyle: @preconcurrency ListItemStyle, BaseThemeDependencies {
    public var id = String(describing: Self.self)
    
    @Dependency(\.themeConfigurator) public var themeConfigurator: any ThemeConfiguratorProtocol
    
    public init() {}
    
    @MainActor
    public func makeBody(configuration: Configuration) -> some View {
        BaseListItem(configuration: configuration)
    }
}

public extension ListItemStyle where Self == DefaultListItemStyle {
    static func `default`() -> Self { .init() }
}

public enum ListItemStyleCase: CaseIterable, Identifiable {
    case `default`
    
    public var id: Self { self }
    
    public func style() -> AnyListItemStyle {
        switch self {
        case .default:
            .init(.default())
        }
    }
}

private struct BaseListItem: @preconcurrency View, @preconcurrency BaseThemeDependencies {
    @Dependency(\.themeConfigurator) public var themeConfigurator: any ThemeConfiguratorProtocol
    
    let configuration: ListItemStyleConfiguration
    
    init(configuration: ListItemStyleConfiguration) {
        self.configuration = configuration
    }
    
    fileprivate func info(
        title: String,
        description: String,
        alignment: HorizontalAlignment
    ) -> some View {
        return VStack(
            alignment: alignment,
            spacing: spacings.extraSmall
        ) {
            Text(title)
                .textStyle(.small(.contentB))
            Text(description)
                .textStyle(.small(.contentA))
        }
    }
    
    var body: some View {
        Card(alignment: .center, type: .fill, action: {
            configuration.action()
        }) {
            Blur {
                Stack(arrangement: .vertical(alignment: .leading)) {
                    VStack(alignment: .leading, spacing: spacings.medium) {
                        HStack(alignment: .top) {
                            Text(configuration.title)
                                .textStyle(.mediumBold(.contentA))
                            Spacer()
                            if let trailingContent = configuration.trailingContent {
                                trailingContent
                            }
                        }
                        if configuration.description.isNotEmpty {
                            Text(configuration.description)
                                .textStyle(.small(.contentB))
                                .padding(.bottom, spacings.small)
                        }
                    }
                    .padding(.bottom, spacings.small)
                    HStack {
                        info(
                            title: configuration.leftInfo.title,
                            description: configuration.leftInfo.description,
                            alignment: .leading
                        )
                        Spacer()
                        info(
                            title: configuration.rightInfo.title,
                            description: configuration.rightInfo.description,
                            alignment: .trailing
                        )
                    }
                }.padding(spacings.medium)
            }
            .blurStyle(configuration.blurStyle.style())
        }
    }
}
