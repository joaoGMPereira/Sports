import SwiftUICore

public struct ColorsMock: ColorsProtocol {
    public let highlightA = Color.red
    
    public let backgroundA = Color.red
    
    public let backgroundB = Color.red
    
    public let backgroundC = Color.red
    
    public let backgroundD = Color.red
    
    public let contentA = Color.red
    
    public let contentB = Color.red
    
    public let contentC = Color.red
    
    public let critical = Color.red
    
    public let attention = Color.red
    
    public let danger = Color.red
    
    public let positive = Color.red
    
    public let none = Color.clear
    
    var colors: [ColorName: Color] {
        [
            .highlightA: highlightA,
            .backgroundA: backgroundA,
            .backgroundB: backgroundB,
            .backgroundC: backgroundC,
            .backgroundD: backgroundD,
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


public struct FontsMock: FontsProtocol {
    public let baseSmall = BaseFont(
        font: .callout,
        fontLineHeight: 16,
        lineHeight: 24
    )
    
    public let baseSmallBold = BaseFont(
        font: .caption,
        fontLineHeight: 16,
        lineHeight: 24
    )
    
    public let baseMedium = BaseFont(
        font: .body,
        fontLineHeight: 20,
        lineHeight: 24
    )
    
    public let baseMediumBold = BaseFont(
        font: .body,
        fontLineHeight: 20,
        lineHeight: 24
    )
    
    public let baseLarge = BaseFont(
        font: .title,
        fontLineHeight: 24,
        lineHeight: 32
    )
    
    /// Fonte para títulos de seções e botões principais
    public let baseLargeBold = BaseFont(
        font: .title,
        fontLineHeight: 32,
        lineHeight: 40
    )
    
    public let baseBigBold = BaseFont(
        font: .headline,
        fontLineHeight: 56,
        lineHeight: 64
    )
    
    public func font(by fontName: FontName) -> Font? {
        fonts[fontName]?.font
    }
}


public struct SpacingsMock: SpacingsProtocol {
    /// Nenhum espaçamento
    public let none: Double = 0
    
    /// Espaçamento mínimo, usado para pequenos ajustes
    public let extraSmall: Double = 4
    
    /// Espaçamento pequeno, geralmente usado para margens e paddings sutis
    public let small: Double = 8
    
    /// Espaçamento padrão, usado na maioria dos componentes
    public let medium: Double = 16
    
    /// Espaçamento grande, usado para separar seções
    public let large: Double = 24
    
    /// Espaçamento extra grande, usado para dar respiro entre blocos de conteúdo
    public let extraLarge: Double = 32
    
    /// Espaçamento gigante, usado em layouts mais amplos
    public let ultra: Double = 64
    
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
    
    public func spacing(by spacingName: SpacingName) -> Double {
        spacings[spacingName] ?? none
    }
}

public struct ConstantsMock: ConstantsProtocol {
    public var tapOpacity: Double = 0.3
    
    public let smallCornerRadius: Double = 8
    public let cornerRadius: Double = 20
    
    public let disabledOpacity: Double = 0.3
    
    public let smallButtonSize: Double = 44
    
    public let mediumButtonSize: Double = 48
    
    public let animationTimer: Double = 0.5
    
    public var strokeColor: Color = Color(hex: "#646161")
}
