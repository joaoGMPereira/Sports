import SwiftUI
import ZenithCoreInterface

extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: Double
        switch hex.count {
        case 6:
            (a, r, g, b) = (1, Double((int >> 16) & 0xFF) / 255, Double((int >> 8) & 0xFF) / 255, Double(int & 0xFF) / 255)
        case 8:
            (a, r, g, b) = (Double((int >> 24) & 0xFF) / 255, Double((int >> 16) & 0xFF) / 255, Double((int >> 8) & 0xFF) / 255, Double(int & 0xFF) / 255)
        default:
            (a, r, g, b) = (1, 0, 0, 0)
        }
        self.init(.sRGB, red: r, green: g, blue: b, opacity: a)
    }
}

enum ColorPrimitiveToken {
    static let black = Color(hex: "#000000")
    static let white = Color(hex: "#FFFFFF")
    
    static let extraLightGray = Color(hex: "F5F5F5")
    static let lightGray = Color(hex: "#444444")
    static let darkGray = Color(hex: "#222222")

    static let purpleSupport = Color(hex: "#A811CD")
    static let yellowSupport = Color(hex: "#FBCC34")
    static let orangeSupport = Color(hex: "#FB9B2E")
    static let redSupport = Color(hex: "#FB3434")
    static let neonGreen = Color(hex: "#B6FB2D")
    static let waterGreen = Color(hex: "#43E58D")
}

public struct LightColors: ColorsProtocol {
    
    public let highlightA = ColorPrimitiveToken.neonGreen
    
    public let background = ColorPrimitiveToken.white
    
    public let backgroundSecondary = ColorPrimitiveToken.extraLightGray
    
    public let backgroundTertiary = ColorPrimitiveToken.extraLightGray
    
    public let textPrimary = ColorPrimitiveToken.black
    
    public let textSecondary = ColorPrimitiveToken.white
    
    public let critical = ColorPrimitiveToken.redSupport
    
    public let attention = ColorPrimitiveToken.yellowSupport
    
    public let danger = ColorPrimitiveToken.orangeSupport
    
    public let positive = ColorPrimitiveToken.waterGreen
    
    var colors: [ColorName: Color] {
        [
            .highlightA: highlightA,
            .background: background,
            .backgroundSecondary: backgroundSecondary,
            .textPrimary: textPrimary,
            .textSecondary: textSecondary,
            .critical: critical,
            .attention: attention,
            .danger: danger,
            .positive: positive,
        ]
    }
    
    public init() {}
    
    public func color(by colorName: ColorName) -> Color? {
        colors[colorName]
    }
}

public struct DarkColors: ColorsProtocol {
    
    public let highlightA = ColorPrimitiveToken.neonGreen
    
    public let background = ColorPrimitiveToken.black
    
    public let backgroundSecondary = ColorPrimitiveToken.darkGray
    
    public let backgroundTertiary = ColorPrimitiveToken.lightGray
    
    public let textPrimary = ColorPrimitiveToken.white
    
    public let textSecondary = ColorPrimitiveToken.black
    
    public let critical = ColorPrimitiveToken.redSupport
    
    public let attention = ColorPrimitiveToken.yellowSupport
    
    public let danger = ColorPrimitiveToken.orangeSupport
    
    public let positive = ColorPrimitiveToken.waterGreen
    
    var colors: [ColorName: Color] {
        [
            .highlightA: highlightA,
            .background: background,
            .backgroundSecondary: backgroundSecondary,
            .backgroundTertiary: backgroundTertiary,
            .textPrimary: textPrimary,
            .textSecondary: textSecondary,
            .critical: critical,
            .attention: attention,
            .danger: danger,
            .positive: positive,
        ]
    }
    
    public func color(by colorName: ColorName) -> Color? {
        colors[colorName]
    }
}
