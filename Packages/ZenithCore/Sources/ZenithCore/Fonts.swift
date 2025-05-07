import SwiftUI
import ZenithCoreInterface

enum FontSize {
    static let size16 = 16.0
    static let size24 = 24.0
    static let size32 = 32.0
    static let size56 = 56.0
}

enum FontLineHeight {
    static let height24 = 24.0
    static let height36 = 36.0
    static let height44 = 44.0
    static let height64 = 64.0
}

public struct Fonts: FontsProtocol, Sendable {
    public let baseSmall = BaseFont(
        font: FontFamily.Gilroy.medium.swiftUIFont(
            size: FontSize.size16,
            relativeTo: .body
        ),
        fontLineHeight: FontSize.size16,
        lineHeight: FontLineHeight.height24
    )

    public let baseSmallBold = BaseFont(
        font: FontFamily.Gilroy.semibold.swiftUIFont(
            size: FontSize.size16,
            relativeTo: .body
        ),
        fontLineHeight: FontSize.size16,
        lineHeight: FontLineHeight.height24
    )
    
    /// Fonte para títulos de seções e botões principais
    public let baseMedium = BaseFont(
        font: FontFamily.Gilroy.semibold.swiftUIFont(
            size: FontSize.size24,
            relativeTo: .title2
        ),
        fontLineHeight: FontSize.size24,
        lineHeight: FontLineHeight.height36
    )
    
    /// Fonte para títulos de seções e botões principais
    public let baseMediumBold = BaseFont(
        font: FontFamily.Gilroy.medium.swiftUIFont(
            size: FontSize.size32,
            relativeTo: .title
        ),
        fontLineHeight: FontSize.size32,
        lineHeight: FontLineHeight.height44
    )
    
    /// Fonte para títulos de destaque e chamadas importantes
    public let baseBigBold = BaseFont(
        font: FontFamily.Gilroy.semibold.swiftUIFont(
            size: FontSize.size56,
            relativeTo: .headline
        ),
        fontLineHeight: FontSize.size56,
        lineHeight: FontLineHeight.height64
    )
    
    var fonts: [FontName: BaseFont] {
        [
            .small: baseSmall,
            .smallBold: baseSmallBold,
            .medium: baseMedium,
            .mediumBold: baseMediumBold,
            .bigBold: baseBigBold
        ]
    }
    
    public var small: Font {
        baseSmall.font
    }
    
    public var smallBold: Font {
        baseSmallBold.font
    }
    
    public var medium: Font {
        baseMedium.font
    }
    
    public var mediumBold: Font {
        baseMediumBold.font
    }
    
    public var bigBold: Font {
        baseBigBold.font
    }

    public func font(by fontName: FontName) -> Font? {
        fonts[fontName]?.font
    }
}
