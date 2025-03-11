import SwiftUI

public enum ColorName: String, Decodable, CaseIterable {
    case primary, background, backgroundSecondary, backgroundTertiary, textPrimary, textSecondary, critical, attention, danger, positive
}

public protocol ColorsProtocol: Sendable, Equatable {
    var primary: Color { get }
    var background: Color { get }
    var backgroundSecondary: Color { get }
    var backgroundTertiary: Color { get }
    var textPrimary: Color { get }
    var textSecondary: Color { get }
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
