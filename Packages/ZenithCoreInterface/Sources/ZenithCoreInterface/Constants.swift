import SwiftUI

public protocol ConstantsProtocol: Sendable, Equatable {
    var disabledOpacity: Double { get }
    var tapOpacity: Double { get }
    var smallButtonSize: Double { get }
    var mediumButtonSize: Double { get }
    var animationTimer: Double { get }
    var smallCornerRadius: Double { get }
    var cornerRadius: Double { get }
    var strokeColor: Color { get }
}
