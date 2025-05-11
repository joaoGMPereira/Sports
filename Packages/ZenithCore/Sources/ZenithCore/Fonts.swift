import SwiftUI
import ZenithCoreInterface

enum FontSize {
    static let size12 = 12.0
    static let size14 = 14.0
    static let size20 = 20.0
    static let size24 = 24.0
    static let size32 = 32.0
    static let size56 = 56.0
}

enum FontLineHeight {
    static let height15 = 15.0
    static let height17 = 17.0
    static let height24 = 24.0
    static let height36 = 36.0
    static let height44 = 44.0
    static let height64 = 64.0
}

public struct Fonts: FontsProtocol, Sendable {
    public let baseExtraSmall = BaseFont(
        font: FontFamily.Gilroy.medium.swiftUIFont(
            size: FontSize.size12,
            relativeTo: .caption
        ),
        fontLineHeight: FontSize.size12,
        lineHeight: FontLineHeight.height15
    )

    public let baseExtraSmallBold = BaseFont(
        font: FontFamily.Gilroy.semibold.swiftUIFont(
            size: FontSize.size12,
            relativeTo: .caption
        ),
        fontLineHeight: FontSize.size12,
        lineHeight: FontLineHeight.height15
    )
    
    public let baseSmall = BaseFont(
        font: FontFamily.Gilroy.medium.swiftUIFont(
            size: FontSize.size14,
            relativeTo: .body
        ),
        fontLineHeight: FontSize.size14,
        lineHeight: FontLineHeight.height17
    )

    public let baseSmallBold = BaseFont(
        font: FontFamily.Gilroy.semibold.swiftUIFont(
            size: FontSize.size14,
            relativeTo: .body
        ),
        fontLineHeight: FontSize.size14,
        lineHeight: FontLineHeight.height17
    )
    
    public let baseMedium = BaseFont(
        font: FontFamily.Gilroy.medium.swiftUIFont(
            size: FontSize.size20,
            relativeTo: .subheadline
        ),
        fontLineHeight: FontSize.size20,
        lineHeight: FontLineHeight.height24
    )
    
    public let baseMediumBold = BaseFont(
        font: FontFamily.Gilroy.semibold.swiftUIFont(
            size: FontSize.size20,
            relativeTo: .subheadline
        ),
        fontLineHeight: FontSize.size20,
        lineHeight: FontLineHeight.height24
    )
    
    public let baseLarge = BaseFont(
        font: FontFamily.Gilroy.semibold.swiftUIFont(
            size: FontSize.size24,
            relativeTo: .title2
        ),
        fontLineHeight: FontSize.size24,
        lineHeight: FontLineHeight.height36
    )
    
    public let baseLargeBold = BaseFont(
        font: FontFamily.Gilroy.medium.swiftUIFont(
            size: FontSize.size32,
            relativeTo: .title
        ),
        fontLineHeight: FontSize.size32,
        lineHeight: FontLineHeight.height44
    )
    
    public let baseBigBold = BaseFont(
        font: FontFamily.Gilroy.semibold.swiftUIFont(
            size: FontSize.size56,
            relativeTo: .headline
        ),
        fontLineHeight: FontSize.size56,
        lineHeight: FontLineHeight.height64
    )

    public func font(by fontName: FontName) -> Font? {
        fonts[fontName]?.font
    }
}
