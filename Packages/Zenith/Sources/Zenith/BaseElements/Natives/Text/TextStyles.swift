import SwiftUI
import ZenithCoreInterface

public extension Text {
    @MainActor
    func textStyle(_ style: some TextStyle) -> some View {
        AnyView(
            style.resolve(
                configuration: TextStyleConfiguration(
                    content: self
                )
            ).environment(\.textStyle, style)
        )
    }
}


@MainActor
public extension TextStyle where Self == BaseTextStyle {
    static func small(_ color: ColorName) -> Self { Self(color: color, fontName: .small) }
    static func medium(_ color: ColorName) -> Self { Self(color: color, fontName: .medium) }
    static func mediumBold(_ color: ColorName) -> Self { Self(color: color, fontName: .mediumBold) }
    static func bigBold(_ color: ColorName) -> Self { Self(color: color, fontName: .bigBold) }
}

@MainActor
public struct BaseTextStyle: @preconcurrency TextStyle, @preconcurrency BaseThemeDependencies {
    public let id = String(describing:Self.self)
    public let textStyleColor: ColorName
    public let fontName: FontName
    
    @Dependency(\.themeConfigurator) public var themeConfigurator
    
    var font: Font {
        fonts.font(by: fontName) ?? fonts.small
    }
    
    var color: Color {
        colors.color(by: textStyleColor) ?? colors.contentA
    }
    
    public init(
        color: ColorName,
        fontName: FontName
    ) {
        self.textStyleColor = color
        self.fontName = fontName
    }
    
    @MainActor
    public func makeBody(configuration: TextStyleConfiguration) -> some View {
        return configuration
            .content
            .font(font)
            .foregroundStyle(color)
    }
}

public enum TextStyleCase: String, Decodable, CaseIterable, Identifiable {
    case smallContentA
    case smallContentB
    case smallHighlightA
    case mediumContentA
    case mediumContentB
    case mediumHighlightA
    case mediumBoldContentA
    case mediumBoldContentB
    case mediumBoldHighlightA
    case bigBoldContentA
    case bigBoldContentB
    case bigBoldHighlightA
    
    public var id: Self { self }
    
    @MainActor
    public func style() -> AnyTextStyle {
        switch self {
        case .smallContentA:
            return .init(BaseTextStyle.small(.contentA))
        case .smallContentB:
            return .init(BaseTextStyle.small(.contentC))
        case .smallHighlightA:
            return .init(BaseTextStyle.small(.highlightA))
        case .mediumContentA:
            return .init(BaseTextStyle.medium(.contentA))
        case .mediumContentB:
            return .init(BaseTextStyle.medium(.contentC))
        case .mediumHighlightA:
            return .init(BaseTextStyle.medium(.highlightA))
        case .mediumBoldContentA:
            return .init(BaseTextStyle.mediumBold(.contentA))
        case .mediumBoldContentB:
            return .init(BaseTextStyle.mediumBold(.contentC))
        case .mediumBoldHighlightA:
            return .init(BaseTextStyle.mediumBold(.highlightA))
        case .bigBoldContentA:
            return .init(BaseTextStyle.bigBold(.contentA))
        case .bigBoldContentB:
            return .init(BaseTextStyle.bigBold(.contentC))
        case .bigBoldHighlightA:
            return .init(BaseTextStyle.bigBold(.highlightA))
        }
    }
}
