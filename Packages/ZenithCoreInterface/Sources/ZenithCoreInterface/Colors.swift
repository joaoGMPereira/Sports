import SwiftUI

public enum ColorName: String, Decodable, CaseIterable {
    case highlightA, backgroundA, backgroundB, backgroundC, contentA, contentB, critical, attention, danger, positive
}

public protocol ColorsProtocol: Sendable, Equatable {
    var highlightA: Color { get }
    var backgroundA: Color { get }
    var backgroundB: Color { get }
    var backgroundC: Color { get }
    var contentA: Color { get }
    var contentB: Color { get }
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
