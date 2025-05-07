import SwiftUI
import ZenithCoreInterface

public extension Text {
    @MainActor
    func textStyle(_ style: some TextStyle) -> some View {
        AnyView(
            style.resolve(
                configuration: TextStyleConfiguration(
                    content: self
                )
            ).environment(\.textStyle, style)
        )
    }
}


@MainActor
public extension TextStyle where Self == BaseTextStyle {
    static func small(_ color: ColorName) -> Self { Self(color: color, fontName: .small) }
    static func medium(_ color: ColorName) -> Self { Self(color: color, fontName: .medium) }
    static func mediumBold(_ color: ColorName) -> Self { Self(color: color, fontName: .mediumBold) }
    static func large(_ color: ColorName) -> Self { Self(color: color, fontName: .large) }
    static func largeBold(_ color: ColorName) -> Self { Self(color: color, fontName: .largeBold) }
    static func bigBold(_ color: ColorName) -> Self { Self(color: color, fontName: .bigBold) }
}

@MainActor
public struct BaseTextStyle: @preconcurrency TextStyle, @preconcurrency BaseThemeDependencies {
    public let id = String(describing:Self.self)
    public let textStyleColor: ColorName
    public let fontName: FontName
    
    @Dependency(\.themeConfigurator) public var themeConfigurator
    
    var font: Font {
        fonts.font(by: fontName) ?? fonts.small
    }
    
    var color: Color {
        colors.color(by: textStyleColor) ?? colors.contentA
    }
    
    public init(
        color: ColorName,
        fontName: FontName
    ) {
        self.textStyleColor = color
        self.fontName = fontName
    }
    
    @MainActor
    public func makeBody(configuration: TextStyleConfiguration) -> some View {
        return configuration
            .content
            .font(font)
            .foregroundStyle(color)
    }
}

public enum TextStyleCase: String, Decodable, CaseIterable, Identifiable {
    // Small font
    case smallHighlightA, smallBackgroundA, smallBackgroundB, smallBackgroundC, smallBackgroundD
    case smallContentA, smallContentB, smallContentC, smallCritical, smallAttention, smallDanger, smallPositive, smallNone
    
    // SmallBold font
    case smallBoldHighlightA, smallBoldBackgroundA, smallBoldBackgroundB, smallBoldBackgroundC, smallBoldBackgroundD
    case smallBoldContentA, smallBoldContentB, smallBoldContentC, smallBoldCritical, smallBoldAttention, smallBoldDanger, smallBoldPositive, smallBoldNone
    
    // Medium font
    case mediumHighlightA, mediumBackgroundA, mediumBackgroundB, mediumBackgroundC, mediumBackgroundD
    case mediumContentA, mediumContentB, mediumContentC, mediumCritical, mediumAttention, mediumDanger, mediumPositive, mediumNone
    
    // MediumBold font
    case mediumBoldHighlightA, mediumBoldBackgroundA, mediumBoldBackgroundB, mediumBoldBackgroundC, mediumBoldBackgroundD
    case mediumBoldContentA, mediumBoldContentB, mediumBoldContentC, mediumBoldCritical, mediumBoldAttention, mediumBoldDanger, mediumBoldPositive, mediumBoldNone
    
    // Large font
    case largeHighlightA, largeBackgroundA, largeBackgroundB, largeBackgroundC, largeBackgroundD
    case largeContentA, largeContentB, largeContentC, largeCritical, largeAttention, largeDanger, largePositive, largeNone
    
    // LargeBold font
    case largeBoldHighlightA, largeBoldBackgroundA, largeBoldBackgroundB, largeBoldBackgroundC, largeBoldBackgroundD
    case largeBoldContentA, largeBoldContentB, largeBoldContentC, largeBoldCritical, largeBoldAttention, largeBoldDanger, largeBoldPositive, largeBoldNone
    
    // BigBold font
    case bigBoldHighlightA, bigBoldBackgroundA, bigBoldBackgroundB, bigBoldBackgroundC, bigBoldBackgroundD
    case bigBoldContentA, bigBoldContentB, bigBoldContentC, bigBoldCritical, bigBoldAttention, bigBoldDanger, bigBoldPositive, bigBoldNone
    
    public var id: Self { self }
    
    @MainActor
    public func style() -> AnyTextStyle {
        switch self {
        // Small font
        case .smallHighlightA:
            return .init(BaseTextStyle(color: .highlightA, fontName: .small))
        case .smallBackgroundA:
            return .init(BaseTextStyle(color: .backgroundA, fontName: .small))
        case .smallBackgroundB:
            return .init(BaseTextStyle(color: .backgroundB, fontName: .small))
        case .smallBackgroundC:
            return .init(BaseTextStyle(color: .backgroundC, fontName: .small))
        case .smallBackgroundD:
            return .init(BaseTextStyle(color: .backgroundD, fontName: .small))
        case .smallContentA:
            return .init(BaseTextStyle(color: .contentA, fontName: .small))
        case .smallContentB:
            return .init(BaseTextStyle(color: .contentB, fontName: .small))
        case .smallContentC:
            return .init(BaseTextStyle(color: .contentC, fontName: .small))
        case .smallCritical:
            return .init(BaseTextStyle(color: .critical, fontName: .small))
        case .smallAttention:
            return .init(BaseTextStyle(color: .attention, fontName: .small))
        case .smallDanger:
            return .init(BaseTextStyle(color: .danger, fontName: .small))
        case .smallPositive:
            return .init(BaseTextStyle(color: .positive, fontName: .small))
        case .smallNone:
            return .init(BaseTextStyle(color: .none, fontName: .small))
            
        // SmallBold font
        case .smallBoldHighlightA:
            return .init(BaseTextStyle(color: .highlightA, fontName: .smallBold))
        case .smallBoldBackgroundA:
            return .init(BaseTextStyle(color: .backgroundA, fontName: .smallBold))
        case .smallBoldBackgroundB:
            return .init(BaseTextStyle(color: .backgroundB, fontName: .smallBold))
        case .smallBoldBackgroundC:
            return .init(BaseTextStyle(color: .backgroundC, fontName: .smallBold))
        case .smallBoldBackgroundD:
            return .init(BaseTextStyle(color: .backgroundD, fontName: .smallBold))
        case .smallBoldContentA:
            return .init(BaseTextStyle(color: .contentA, fontName: .smallBold))
        case .smallBoldContentB:
            return .init(BaseTextStyle(color: .contentB, fontName: .smallBold))
        case .smallBoldContentC:
            return .init(BaseTextStyle(color: .contentC, fontName: .smallBold))
        case .smallBoldCritical:
            return .init(BaseTextStyle(color: .critical, fontName: .smallBold))
        case .smallBoldAttention:
            return .init(BaseTextStyle(color: .attention, fontName: .smallBold))
        case .smallBoldDanger:
            return .init(BaseTextStyle(color: .danger, fontName: .smallBold))
        case .smallBoldPositive:
            return .init(BaseTextStyle(color: .positive, fontName: .smallBold))
        case .smallBoldNone:
            return .init(BaseTextStyle(color: .none, fontName: .smallBold))
            
        // Medium font
        case .mediumHighlightA:
            return .init(BaseTextStyle(color: .highlightA, fontName: .medium))
        case .mediumBackgroundA:
            return .init(BaseTextStyle(color: .backgroundA, fontName: .medium))
        case .mediumBackgroundB:
            return .init(BaseTextStyle(color: .backgroundB, fontName: .medium))
        case .mediumBackgroundC:
            return .init(BaseTextStyle(color: .backgroundC, fontName: .medium))
        case .mediumBackgroundD:
            return .init(BaseTextStyle(color: .backgroundD, fontName: .medium))
        case .mediumContentA:
            return .init(BaseTextStyle(color: .contentA, fontName: .medium))
        case .mediumContentB:
            return .init(BaseTextStyle(color: .contentB, fontName: .medium))
        case .mediumContentC:
            return .init(BaseTextStyle(color: .contentC, fontName: .medium))
        case .mediumCritical:
            return .init(BaseTextStyle(color: .critical, fontName: .medium))
        case .mediumAttention:
            return .init(BaseTextStyle(color: .attention, fontName: .medium))
        case .mediumDanger:
            return .init(BaseTextStyle(color: .danger, fontName: .medium))
        case .mediumPositive:
            return .init(BaseTextStyle(color: .positive, fontName: .medium))
        case .mediumNone:
            return .init(BaseTextStyle(color: .none, fontName: .medium))
            
        // MediumBold font
        case .mediumBoldHighlightA:
            return .init(BaseTextStyle(color: .highlightA, fontName: .mediumBold))
        case .mediumBoldBackgroundA:
            return .init(BaseTextStyle(color: .backgroundA, fontName: .mediumBold))
        case .mediumBoldBackgroundB:
            return .init(BaseTextStyle(color: .backgroundB, fontName: .mediumBold))
        case .mediumBoldBackgroundC:
            return .init(BaseTextStyle(color: .backgroundC, fontName: .mediumBold))
        case .mediumBoldBackgroundD:
            return .init(BaseTextStyle(color: .backgroundD, fontName: .mediumBold))
        case .mediumBoldContentA:
            return .init(BaseTextStyle(color: .contentA, fontName: .mediumBold))
        case .mediumBoldContentB:
            return .init(BaseTextStyle(color: .contentB, fontName: .mediumBold))
        case .mediumBoldContentC:
            return .init(BaseTextStyle(color: .contentC, fontName: .mediumBold))
        case .mediumBoldCritical:
            return .init(BaseTextStyle(color: .critical, fontName: .mediumBold))
        case .mediumBoldAttention:
            return .init(BaseTextStyle(color: .attention, fontName: .mediumBold))
        case .mediumBoldDanger:
            return .init(BaseTextStyle(color: .danger, fontName: .mediumBold))
        case .mediumBoldPositive:
            return .init(BaseTextStyle(color: .positive, fontName: .mediumBold))
        case .mediumBoldNone:
            return .init(BaseTextStyle(color: .none, fontName: .mediumBold))
            
        // Large font
        case .largeHighlightA:
            return .init(BaseTextStyle(color: .highlightA, fontName: .large))
        case .largeBackgroundA:
            return .init(BaseTextStyle(color: .backgroundA, fontName: .large))
        case .largeBackgroundB:
            return .init(BaseTextStyle(color: .backgroundB, fontName: .large))
        case .largeBackgroundC:
            return .init(BaseTextStyle(color: .backgroundC, fontName: .large))
        case .largeBackgroundD:
            return .init(BaseTextStyle(color: .backgroundD, fontName: .large))
        case .largeContentA:
            return .init(BaseTextStyle(color: .contentA, fontName: .large))
        case .largeContentB:
            return .init(BaseTextStyle(color: .contentB, fontName: .large))
        case .largeContentC:
            return .init(BaseTextStyle(color: .contentC, fontName: .large))
        case .largeCritical:
            return .init(BaseTextStyle(color: .critical, fontName: .large))
        case .largeAttention:
            return .init(BaseTextStyle(color: .attention, fontName: .large))
        case .largeDanger:
            return .init(BaseTextStyle(color: .danger, fontName: .large))
        case .largePositive:
            return .init(BaseTextStyle(color: .positive, fontName: .large))
        case .largeNone:
            return .init(BaseTextStyle(color: .none, fontName: .large))
            
        // LargeBold font
        case .largeBoldHighlightA:
            return .init(BaseTextStyle(color: .highlightA, fontName: .largeBold))
        case .largeBoldBackgroundA:
            return .init(BaseTextStyle(color: .backgroundA, fontName: .largeBold))
        case .largeBoldBackgroundB:
            return .init(BaseTextStyle(color: .backgroundB, fontName: .largeBold))
        case .largeBoldBackgroundC:
            return .init(BaseTextStyle(color: .backgroundC, fontName: .largeBold))
        case .largeBoldBackgroundD:
            return .init(BaseTextStyle(color: .backgroundD, fontName: .largeBold))
        case .largeBoldContentA:
            return .init(BaseTextStyle(color: .contentA, fontName: .largeBold))
        case .largeBoldContentB:
            return .init(BaseTextStyle(color: .contentB, fontName: .largeBold))
        case .largeBoldContentC:
            return .init(BaseTextStyle(color: .contentC, fontName: .largeBold))
        case .largeBoldCritical:
            return .init(BaseTextStyle(color: .critical, fontName: .largeBold))
        case .largeBoldAttention:
            return .init(BaseTextStyle(color: .attention, fontName: .largeBold))
        case .largeBoldDanger:
            return .init(BaseTextStyle(color: .danger, fontName: .largeBold))
        case .largeBoldPositive:
            return .init(BaseTextStyle(color: .positive, fontName: .largeBold))
        case .largeBoldNone:
            return .init(BaseTextStyle(color: .none, fontName: .largeBold))
            
        // BigBold font
        case .bigBoldHighlightA:
            return .init(BaseTextStyle(color: .highlightA, fontName: .bigBold))
        case .bigBoldBackgroundA:
            return .init(BaseTextStyle(color: .backgroundA, fontName: .bigBold))
        case .bigBoldBackgroundB:
            return .init(BaseTextStyle(color: .backgroundB, fontName: .bigBold))
        case .bigBoldBackgroundC:
            return .init(BaseTextStyle(color: .backgroundC, fontName: .bigBold))
        case .bigBoldBackgroundD:
            return .init(BaseTextStyle(color: .backgroundD, fontName: .bigBold))
        case .bigBoldContentA:
            return .init(BaseTextStyle(color: .contentA, fontName: .bigBold))
        case .bigBoldContentB:
            return .init(BaseTextStyle(color: .contentB, fontName: .bigBold))
        case .bigBoldContentC:
            return .init(BaseTextStyle(color: .contentC, fontName: .bigBold))
        case .bigBoldCritical:
            return .init(BaseTextStyle(color: .critical, fontName: .bigBold))
        case .bigBoldAttention:
            return .init(BaseTextStyle(color: .attention, fontName: .bigBold))
        case .bigBoldDanger:
            return .init(BaseTextStyle(color: .danger, fontName: .bigBold))
        case .bigBoldPositive:
            return .init(BaseTextStyle(color: .positive, fontName: .bigBold))
        case .bigBoldNone:
            return .init(BaseTextStyle(color: .none, fontName: .bigBold))
        }
    }
}
