import SwiftUI

public enum FontName: String, Decodable, CaseIterable, Sendable {
    case small, medium, mediumBold, bigBold
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
    var baseMedium: BaseFont { get }
    var baseMediumBold: BaseFont { get }
    var baseBigBold: BaseFont { get }
    
    var small: Font { get }
    var medium: Font { get }
    var mediumBold: Font { get }
    var bigBold: Font { get }
    
    func font(by fontName: FontName) -> Font?
}
