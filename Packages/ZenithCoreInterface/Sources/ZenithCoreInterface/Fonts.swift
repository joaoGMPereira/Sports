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
    var small: BaseFont { get }
    var medium: BaseFont { get }
    var mediumBold: BaseFont { get }
    var bigBold: BaseFont { get }
    
    func font(by fontName: FontName) -> BaseFont?
}
