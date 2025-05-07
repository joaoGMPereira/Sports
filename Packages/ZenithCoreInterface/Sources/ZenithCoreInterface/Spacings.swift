

enum SpacingPrimitiveToken {
    static let spacing0 = 0.0
    static let spacing1 = 4.0
    static let spacing2 = 8.0
    static let spacing3 = 12.0
    static let spacing4 = 16.0
    static let spacing5 = 20.0
    static let spacing6 = 24.0
    static let spacing7 = 32.0
    static let spacing8 = 40.0
    static let spacing9 = 48.0
    static let spacing10 = 64.0
}

public protocol SpacingsProtocol: Sendable, Equatable {
    /// 0 Spacing
    var none: Double { get }
    /// 4 Spacing
    var extraSmall: Double { get }
    /// 8 Spacing
    var small: Double { get }
    /// 16 Spacing
    var medium: Double { get }
    /// 20 Spacing
    var large: Double { get }
    /// 32 Spacing
    var extraLarge: Double { get }
    /// 64 Spacing
    var ultra: Double { get }
    
    func spacing(by spacingName: SpacingName) -> Double
}

public enum SpacingName: String, Decodable, CaseIterable {
    case none, extraSmall, small, medium, large, extraLarge, ultra
}
