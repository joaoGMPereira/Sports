import SwiftUI
import ZenithCoreInterface

public extension View {
    func detailedListItemStyle(_ style: some DetailedListItemStyle) -> some View {
        environment(\.detailedListItemStyle, style)
    }
}

// Estilo principal que aceita um ColorName como parâmetro
public struct DefaultDetailedListItemStyle: @preconcurrency DetailedListItemStyle, BaseThemeDependencies {
    public var id = String(describing: Self.self)
    
    @Dependency(\.themeConfigurator) public var themeConfigurator: any ThemeConfiguratorProtocol
    
    let colorName: ColorName
    let blurConfig: BlurConfig
    
    public init(
        colorName: ColorName = .highlightA,
        blurConfig: BlurConfig = .standard()
    ) {
        self.colorName = colorName
        self.blurConfig = blurConfig
    }
    
    @MainActor
    public func makeBody(configuration: Configuration) -> some View {
        BaseDetailedListItem(
            configuration: configuration,
            colorName: colorName
        )
    }
}

// Factory para o estilo padrão
public extension DetailedListItemStyle where Self == DefaultDetailedListItemStyle {
    static func `default`(
        _ colorName: ColorName = .highlightA
    ) -> Self {
        .init(
            colorName: colorName
        )
    }
}

// Enum para casos de estilo
public enum DetailedListItemStyleCase: Identifiable, CaseIterable, Hashable {
    case `default`(ColorName)
    
    public var id: String {
        switch self {
        case .default(let colorName):
            return "default_\(colorName.rawValue)"
        }
    }
    
    public static var allCases: [DetailedListItemStyleCase] {
        var cases: [DetailedListItemStyleCase] = []
        ColorName.allCases.forEach { colorName in
            cases.append(.default(colorName))
        }
        return cases
    }
    
    public func style() -> AnyDetailedListItemStyle {
        switch self {
        case .default(let colorName):
            return .init(.default(colorName))
        }
    }
}

private struct BaseDetailedListItem: @preconcurrency View, @preconcurrency BaseThemeDependencies {
    @Dependency(\.themeConfigurator) public var themeConfigurator: any ThemeConfiguratorProtocol
    
    let configuration: DetailedListItemStyleConfiguration
    let colorName: ColorName
    
    var bottomSpacing: CGFloat {
        if configuration.progressConfig != nil {
            return spacings.none
        }
        
        return configuration.description.isEmpty ? spacings.extraLarge : spacings.none
    }
    
    init(
        configuration: DetailedListItemStyleConfiguration,
        colorName: ColorName
    ) {
        self.configuration = configuration
        self.colorName = colorName
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
            Blur(
                blur1Width: configuration.blurConfig.blur1Width,
                blur1Height: configuration.blurConfig.blur1Height,
                blur1Radius: configuration.blurConfig.blur1Radius,
                blur1OffsetX: configuration.blurConfig.blur1OffsetX,
                blur1OffsetY: configuration.blurConfig.blur1OffsetY,
                blur1Opacity: configuration.blurConfig.blur1Opacity,
                
                blur2Width: configuration.blurConfig.blur2Width,
                blur2Height: configuration.blurConfig.blur2Height,
                blur2Radius: configuration.blurConfig.blur2Radius,
                blur2OffsetX: configuration.blurConfig.blur2OffsetX,
                blur2OffsetY: configuration.blurConfig.blur2OffsetY,
                blur2Opacity: configuration.blurConfig.blur2Opacity,
                
                blur3Width: configuration.blurConfig.blur3Width,
                blur3Height: configuration.blurConfig.blur3Height,
                blur3Radius: configuration.blurConfig.blur3Radius,
                blur3OffsetX: configuration.blurConfig.blur3OffsetX,
                blur3OffsetY: configuration.blurConfig.blur3OffsetY,
                blur3Opacity: configuration.blurConfig.blur3Opacity
            ) {
                Stack(arrangement: .vertical(alignment: .leading)) {
                    VStack(alignment: .leading, spacing: spacings.medium) {
                        HStack(alignment: configuration.progressText == nil ? .top : .center) {
                            Text(configuration.title)
                                .textStyle(.medium(.contentA))
                            Spacer()
                            
                            // Priority rendering order:
                            // 1. trailingContent (custom content)
                            // 2. progressConfig (CircularProgress configuration)
                            // 3. progressText (simple text)
                            if let trailingContent = configuration.trailingContent {
                                trailingContent
                            } else if let progressConfig = configuration.progressConfig {
                                CircularProgress(configuration: progressConfig)
                                    .circularProgressStyle(circularProgressStyle(colorName).style())
                            } else if let progressText = configuration.progressText {
                                Text(progressText)
                                    .textStyle(.small(colorName))
                            }
                        }
                        .padding(.bottom, bottomSpacing)
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
            .blurStyle(.default(colorName))
        }
    }
    
    func circularProgressStyle(_ color: ColorName) -> CircularProgressStyleCase {
        switch color {
        case .highlightA:
            .highlightA
        case .contentA:
            .contentA
        case .contentB:
            .contentB
        default:
            .highlightA
        }
    }
}
