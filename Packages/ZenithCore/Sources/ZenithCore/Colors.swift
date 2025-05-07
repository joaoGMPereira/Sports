import SwiftUI
import ZenithCoreInterface

enum ColorPrimitiveToken {
    static let black = Color(hex: "#0E0E11")
    static let white = Color(hex: "#FFFFFF")
    
    static let gray = Color(hex: "#BCBCBC")
    static let extraLightGray = Color(hex: "#F5F5F5")
    static let lightGray = Color(hex: "#444444")
    static let darkGray = Color(hex: "#222222")
    static let grayWithOpacity = Color(hex: "#802F2F35")

    static let purpleSupport = Color(hex: "#A811CD")
    static let yellowSupport = Color(hex: "#EDFF22")
    static let orangeSupport = Color(hex: "#FB9B2E")
    static let redSupport = Color(hex: "#FF1F1F")
    static let neonGreen = Color(hex: "#B6FB2D")
    static let waterGreen = Color(hex: "#43E58D")
}

public struct DarkColors: ColorsProtocol {
    
    public let highlightA = ColorPrimitiveToken.neonGreen
    
    public let backgroundA = ColorPrimitiveToken.black
    
    public let backgroundB = ColorPrimitiveToken.darkGray
    
    public let backgroundC = ColorPrimitiveToken.lightGray
    
    public var backgroundD = ColorPrimitiveToken.grayWithOpacity
    
    public let contentA = ColorPrimitiveToken.white
    
    public let contentB = ColorPrimitiveToken.gray
    
    public var contentC = ColorPrimitiveToken.black
    
    public let critical = ColorPrimitiveToken.redSupport
    
    public let attention = ColorPrimitiveToken.yellowSupport
    
    public let danger = ColorPrimitiveToken.orangeSupport
    
    public let positive = ColorPrimitiveToken.waterGreen
    
    public let none = Color.clear
    
    var colors: [ColorName: Color] {
        [
            .highlightA: highlightA,
            .backgroundA: backgroundA,
            .backgroundB: backgroundB,
            .backgroundC: backgroundC,
            .contentA: contentA,
            .contentB: contentB,
            .contentC: contentC,
            .critical: critical,
            .attention: attention,
            .danger: danger,
            .positive: positive,
            .none: none
        ]
    }
    
    public func color(by colorName: ColorName) -> Color? {
        colors[colorName]
    }
}
