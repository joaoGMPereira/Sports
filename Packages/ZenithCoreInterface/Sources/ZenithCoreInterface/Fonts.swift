import SwiftUI

public enum FontName: String, Decodable, CaseIterable, Sendable {
    case small, smallBold, medium, mediumBold, large, largeBold, bigBold
}

protocol FontProtocol {
    var font: Font { get }
    var fontLineHeight: Double { get }
    var lineHeight: Double { get }
}

public struct BaseFont: FontProtocol, Sendable, Equatable {
    public let font: Font
    public let fontLineHeight: Double
    public let lineHeight: Double
    
    public init(
        font: Font,
        fontLineHeight: Double,
        lineHeight: Double
    ) {
        self.font = font
        self.fontLineHeight = fontLineHeight
        self.lineHeight = lineHeight
    }
}

public protocol FontsProtocol: Sendable, Equatable {
    var baseSmall: BaseFont { get }
    var baseSmallBold: BaseFont { get }
    var baseMedium: BaseFont { get }
    var baseMediumBold: BaseFont { get }
    var baseLarge: BaseFont { get }
    var baseLargeBold: BaseFont { get }
    var baseBigBold: BaseFont { get }
    
    var small: Font { get }
    var smallBold: Font { get }
    var medium: Font { get }
    var mediumBold: Font { get }
    var large: Font { get }
    var largeBold: Font { get }
    var bigBold: Font { get }
    
    func font(by fontName: FontName) -> Font?
}

public extension FontsProtocol {
    var fonts: [FontName: BaseFont] {
        [
            .small: baseSmall,
            .smallBold: baseSmallBold,
            .medium: baseMedium,
            .mediumBold: baseMediumBold,
            .large: baseLarge,
            .largeBold: baseLargeBold,
            .bigBold: baseBigBold
        ]
    }
    
    var small: Font {
        baseSmall.font
    }
    
    var smallBold: Font {
        baseSmallBold.font
    }
    
    var medium: Font {
        baseMedium.font
    }
    
    var mediumBold: Font {
        baseMediumBold.font
    }
    
    var large: Font {
        baseLarge.font
    }
    
    var largeBold: Font {
        baseLargeBold.font
    }
    
    var bigBold: Font {
        baseBigBold.font
    }
}
