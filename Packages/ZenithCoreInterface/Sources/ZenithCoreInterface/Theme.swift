import SwiftUI

public enum ThemeName: String, Decodable, CaseIterable, Equatable, Sendable, Identifiable {
    case light, dark

    public var id: String { self.rawValue }
}

public protocol ThemeProtocol: Sendable, Equatable {
    
    var name: ThemeName { get }
    var colors: any ColorsProtocol & Sendable { get }
    var fonts: any FontsProtocol & Sendable { get }
    var spacings: any SpacingsProtocol & Sendable { get }
    var constants: any ConstantsProtocol & Sendable { get }
}

public struct Theme: ThemeProtocol, Sendable {
    public let colors: any ColorsProtocol & Sendable
    
    public let fonts: (any FontsProtocol & Sendable)
    
    public let spacings: any SpacingsProtocol & Sendable
    
    public let constants: any ConstantsProtocol & Sendable
    
    public let name: ThemeName
    
    public init(name: ThemeName, colors: any ColorsProtocol & Sendable, fonts: any FontsProtocol & Sendable, spacings: any SpacingsProtocol & Sendable, constants: any ConstantsProtocol & Sendable) {
        self.colors = colors
        self.fonts = fonts
        self.spacings = spacings
        self.constants = constants
        self.name = name
    }
    
    public static func == (lhs: Theme, rhs: Theme) -> Bool {
        lhs.name == rhs.name
    }
}
