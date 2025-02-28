import SwiftUI
import ZenithCoreInterface

public protocol TextStyle: ViewModifier, Identifiable where ID == String {
}

public extension Text {
    func textStyle<T: TextStyle>(_ style: T) -> some View {
        modifier(style)
    }
}

public extension TextStyle where Self == BaseTextStyle {
    static func small(_ color: TextStyleColor) -> Self { Self(color: color, fontName: .small) }
    static func medium(_ color: TextStyleColor) -> Self { Self(color: color, fontName: .medium) }
    static func mediumBold(_ color: TextStyleColor) -> Self { Self(color: color, fontName: .mediumBold) }
    static func bigBold(_ color: TextStyleColor) -> Self { Self(color: color, fontName: .bigBold) }
}

public struct BaseTextStyle: TextStyle, @preconcurrency BaseThemeDependencies {
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
    
    public func body(content: Content) -> some View {
        content
            .font(font.font)
            .lineSpacing(font.lineHeight - font.fontLineHeight)
            .padding(.vertical, (font.lineHeight - font.fontLineHeight) / 2)
            .foregroundStyle(color)
    }
}

public enum TextStyleColor: CaseIterable, Identifiable {
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

public enum TextStyleCase: CaseIterable, Identifiable {
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
    public func modifier() -> AnyViewModifier {
        switch self {
        case .smallTextPrimary:
            return AnyViewModifier(BaseTextStyle.small(.textPrimary))
        case .smallTextSecondary:
            return AnyViewModifier(BaseTextStyle.small(.textSecondary))
        case .smallPrimary:
            return AnyViewModifier(BaseTextStyle.small(.primary))
        case .mediumTextPrimary:
            return AnyViewModifier(BaseTextStyle.medium(.textPrimary))
        case .mediumTextSecondary:
            return AnyViewModifier(BaseTextStyle.medium(.textSecondary))
        case .mediumPrimary:
            return AnyViewModifier(BaseTextStyle.medium(.primary))
        case .mediumBoldTextPrimary:
            return AnyViewModifier(BaseTextStyle.mediumBold(.textPrimary))
        case .mediumBoldTextSecondary:
            return AnyViewModifier(BaseTextStyle.mediumBold(.textSecondary))
        case .mediumBoldPrimary:
            return AnyViewModifier(BaseTextStyle.mediumBold(.primary))
        case .BigBoldTextPrimary:
            return AnyViewModifier(BaseTextStyle.bigBold(.textPrimary))
        case .BigBoldTextSecondary:
            return AnyViewModifier(BaseTextStyle.bigBold(.textSecondary))
        case .BigBoldPrimary:
            return AnyViewModifier(BaseTextStyle.bigBold(.primary))
        }
    }
}
