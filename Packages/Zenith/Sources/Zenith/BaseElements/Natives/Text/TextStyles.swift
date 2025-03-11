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
    static func small(_ color: TextStyleColor) -> Self { Self(color: color, fontName: .small) }
    static func medium(_ color: TextStyleColor) -> Self { Self(color: color, fontName: .medium) }
    static func mediumBold(_ color: TextStyleColor) -> Self { Self(color: color, fontName: .mediumBold) }
    static func bigBold(_ color: TextStyleColor) -> Self { Self(color: color, fontName: .bigBold) }
}

@MainActor
public struct BaseTextStyle: @preconcurrency TextStyle, @preconcurrency BaseThemeDependencies {
    public let id = String(describing:Self.self)
    public let textStyleColor: TextStyleColor
    public let fontName: FontName
    
    @Dependency(\.themeConfigurator) public var themeConfigurator
    
    var font: BaseFont {
        fonts.font(by: fontName) ?? fonts.small
    }
    
    var color: Color {
        colors.color(by: textStyleColor.color) ?? colors.textPrimary
    }
    
    public init(
        color: TextStyleColor,
        fontName: FontName
    ) {
        self.textStyleColor = color
        self.fontName = fontName
    }
    
    @MainActor
    public func makeBody(configuration: TextStyleConfiguration) -> some View {
        configuration
            .content
            .font(font.font)
            .lineSpacing(font.lineHeight - font.fontLineHeight)
            .padding(.vertical, (font.lineHeight - font.fontLineHeight) / 2)
            .foregroundStyle(color)
    }
}

public enum TextStyleColor: String, Decodable, CaseIterable, Identifiable, Sendable {
    case textPrimary
    case textSecondary
    case primary
    
    public var id: Self { self }
    
    var color: ColorName {
        switch self {
        case .textPrimary:
            .textPrimary
        case .textSecondary:
            .textSecondary
        case .primary:
            .primary
        }
    }
}

public enum TextStyleCase: String, Decodable, CaseIterable, Identifiable {
    case smallTextPrimary
    case smallTextSecondary
    case smallPrimary
    case mediumTextPrimary
    case mediumTextSecondary
    case mediumPrimary
    case mediumBoldTextPrimary
    case mediumBoldTextSecondary
    case mediumBoldPrimary
    case BigBoldTextPrimary
    case BigBoldTextSecondary
    case BigBoldPrimary
    
    public var id: Self { self }
    
    @MainActor
    public func style() -> AnyTextStyle {
        switch self {
        case .smallTextPrimary:
            return .init(BaseTextStyle.small(.textPrimary))
        case .smallTextSecondary:
            return .init(BaseTextStyle.small(.textSecondary))
        case .smallPrimary:
            return .init(BaseTextStyle.small(.primary))
        case .mediumTextPrimary:
            return .init(BaseTextStyle.medium(.textPrimary))
        case .mediumTextSecondary:
            return .init(BaseTextStyle.medium(.textSecondary))
        case .mediumPrimary:
            return .init(BaseTextStyle.medium(.primary))
        case .mediumBoldTextPrimary:
            return .init(BaseTextStyle.mediumBold(.textPrimary))
        case .mediumBoldTextSecondary:
            return .init(BaseTextStyle.mediumBold(.textSecondary))
        case .mediumBoldPrimary:
            return .init(BaseTextStyle.mediumBold(.primary))
        case .BigBoldTextPrimary:
            return .init(BaseTextStyle.bigBold(.textPrimary))
        case .BigBoldTextSecondary:
            return .init(BaseTextStyle.bigBold(.textSecondary))
        case .BigBoldPrimary:
            return .init(BaseTextStyle.bigBold(.primary))
        }
    }
}
