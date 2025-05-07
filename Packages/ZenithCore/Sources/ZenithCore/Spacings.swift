import ZenithCoreInterface

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

public struct Spacings: SpacingsProtocol {
    /// Nenhum espaçamento
    public let none = SpacingPrimitiveToken.spacing0
    
    /// Espaçamento mínimo, usado para pequenos ajustes
    public let extraSmall = SpacingPrimitiveToken.spacing1
    
    /// Espaçamento pequeno, geralmente usado para margens e paddings sutis
    public let small = SpacingPrimitiveToken.spacing2
    
    /// Espaçamento padrão, usado na maioria dos componentes
    public let medium = SpacingPrimitiveToken.spacing4
    
    /// Espaçamento grande, usado para separar seções
    public let large = SpacingPrimitiveToken.spacing5
    
    /// Espaçamento extra grande, usado para dar respiro entre blocos de conteúdo
    public let extraLarge = SpacingPrimitiveToken.spacing7
    
    /// Espaçamento gigante, usado em layouts mais amplos
    public let ultra = SpacingPrimitiveToken.spacing10
    
    var spacings: [SpacingName: Double] {
        [
            .none: none,
            .small: small,
            .medium: medium,
            .large: large,
            .extraLarge: extraLarge,
            .ultra: ultra
        ]
    }
    
    public init() {}
    
    public func spacing(by spacingName: SpacingName) -> Double {
        spacings[spacingName] ?? none
    }
}
