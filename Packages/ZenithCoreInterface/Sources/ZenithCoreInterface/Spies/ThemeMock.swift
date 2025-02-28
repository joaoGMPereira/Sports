#if DEBUG
import SwiftUICore

public struct ColorsMock: ColorsProtocol {
    public let primary = Color.red
    
    public let background = Color.red
    
    public let backgroundSecondary = Color.red
    
    public let backgroundTertiary = Color.red
    
    public let textPrimary = Color.red
    
    public let textSecondary = Color.red
    
    public let critical = Color.red
    
    public let attention = Color.red
    
    public let danger = Color.red
    
    public let positive = Color.red
    
    var colors: [ColorName: Color] {
        [
            .primary: primary,
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
    
    public func color(by colorName: ColorName) -> Color? {
        colors[colorName]
    }
}


public struct FontsMock: FontsProtocol {
    /// Fonte para texto auxiliar e etiquetas
    public let small = BaseFont(
        font: .callout,
        fontLineHeight: 16,
        lineHeight: 24
    )
    
    /// Fonte para títulos de seções e botões principais
    public let medium = BaseFont(
        font: .body,
        fontLineHeight: 24,
        lineHeight: 32
    )
    
    /// Fonte para títulos de seções e botões principais
    public let mediumBold = BaseFont(
        font: .title,
        fontLineHeight: 32,
        lineHeight: 40
    )
    
    /// Fonte para títulos de destaque e chamadas importantes
    public let bigBold = BaseFont(
        font: .headline,
        fontLineHeight: 56,
        lineHeight: 64
    )
    
    var fonts: [FontName: BaseFont] {
        [
            .small: small,
            .medium: medium,
            .mediumBold: mediumBold,
            .bigBold: bigBold
        ]
    }
    
    public func font(by fontName: FontName) -> BaseFont? {
        fonts[fontName]
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
    public let disabledOpacity: Double = 0.3
    
    public let smallButtonSize: Double = 44
    public let mediumButtonSize: Double = 48
    
    public let animationTimer: Double = 0.5
}
#endif
