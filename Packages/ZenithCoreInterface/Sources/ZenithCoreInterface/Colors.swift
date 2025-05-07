import SwiftUI

public enum ColorName: String, Decodable, CaseIterable {
    case highlightA,
         backgroundA,
         backgroundB,
         backgroundC,
         backgroundD,
         contentA,
         contentB,
         contentC,
         critical,
         attention,
         danger,
         positive
}

public protocol ColorsProtocol: Sendable, Equatable {
    var highlightA: Color { get }
    var backgroundA: Color { get }
    var backgroundB: Color { get }
    var backgroundC: Color { get }
    var backgroundD: Color { get }
    var contentA: Color { get }
    var contentB: Color { get }
    var contentC: Color { get }
    var critical: Color { get }
    var attention: Color { get }
    var danger: Color { get }
    var positive: Color { get }
    
    func color(by colorName: ColorName) -> Color?
}

public extension Color {
    func uiColor() -> UIColor {
        UIColor(self)
    }
}

public extension Color {
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
