import SwiftUICore

public struct ColorsMock: ColorsProtocol {
    public let highlightA = Color.red
    
    public let backgroundA = Color.red
    
    public let backgroundB = Color.red
    
    public let backgroundC = Color.red
    
    public let contentA = Color.red
    
    public let contentB = Color.red
    
    public let critical = Color.red
    
    public let attention = Color.red
    
    public let danger = Color.red
    
    public let positive = Color.red
    
    var colors: [ColorName: Color] {
        [
            .highlightA: highlightA,
            .backgroundA: backgroundA,
            .backgroundB: backgroundB,
            .contentA: contentA,
            .contentB: contentB,
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


public struct FontsMock: FontsProtocol {
    /// Fonte para texto auxiliar e etiquetas
    public let baseSmall = BaseFont(
        font: .callout,
        fontLineHeight: 16,
        lineHeight: 24
    )
    
    /// Fonte para títulos de seções e botões principais
    public let baseMedium = BaseFont(
        font: .body,
        fontLineHeight: 24,
        lineHeight: 32
    )
    
    /// Fonte para títulos de seções e botões principais
    public let baseMediumBold = BaseFont(
        font: .title,
        fontLineHeight: 32,
        lineHeight: 40
    )
    
    /// Fonte para títulos de destaque e chamadas importantes
    public let baseBigBold = BaseFont(
        font: .headline,
        fontLineHeight: 56,
        lineHeight: 64
    )
    
    var fonts: [FontName: BaseFont] {
        [
            .small: baseSmall,
            .medium: baseMedium,
            .mediumBold: baseMediumBold,
            .bigBold: baseBigBold
        ]
    }
    
    public var small: Font {
        baseSmall.font
    }
    
    public var medium: Font {
        baseMedium.font
    }
    
    public var mediumBold: Font {
        baseMediumBold.font
    }
    
    public var bigBold: Font {
        baseBigBold.font
    }
    
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
    
    public let disabledOpacity: Double = 0.3
    
    public let smallButtonSize: Double = 44
    public let mediumButtonSize: Double = 48
    
    public let animationTimer: Double = 0.5
}
