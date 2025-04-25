import SwiftUI
import ZenithCoreInterface

public struct AnyButtonStyle: ButtonStyle {
    public let id: UUID = .init()
    
    private let _makeBody: (ButtonStyleConfiguration) -> AnyView
    
    public init<S: ButtonStyle>(_ style: S) {
        _makeBody = { configuration in
            AnyView(style.makeBody(configuration: configuration))
        }
    }
    
    public func makeBody(configuration: ButtonStyleConfiguration) -> some View {
        _makeBody(configuration)
    }
}

public struct ContentAButtonStyle: ButtonStyle, @preconcurrency BaseThemeDependencies {
    @Dependency(\.themeConfigurator) public var themeConfigurator
    
    let shape: ButtonShape
    let state: DSState
    
    public func makeBody(configuration: Configuration) -> some View {
        let contentColor = state == .enabled ? colors.contentA : colors.contentA.opacity(constants.disabledOpacity)
        configuration
            .label
            .font(fonts.small)
            .padding(spacings.medium)
            .background(
                buildShapeView(
                    shape,
                    isPressed: configuration.isPressed,
                    fillColor: colors.contentA.opacity(constants.tapOpacity),
                    strokeColor: contentColor
                )
            )
            .foregroundColor(contentColor)
            .animation(.default, value: configuration.isPressed)
            .allowsHitTesting(state == .enabled)
    }
    
    @ViewBuilder
    private func buildShapeView(_ shapeType: ButtonShape, isPressed: Bool, fillColor: Color, strokeColor: Color) -> some View {
        let shape: AnyShape = {
            switch shapeType {
            case .circle:
                return AnyShape(Circle())
            case .rounded(let radius):
                return AnyShape(RoundedRectangle(cornerRadius: radius))
            }
        }()
        
        shape
            .fill(isPressed ? fillColor : .clear)
            .overlay(
                shape.stroke(strokeColor, lineWidth: 1)
            )
    }
}

public struct HighlightAButtonStyle: ButtonStyle, @preconcurrency BaseThemeDependencies {
    @Dependency(\.themeConfigurator) public var themeConfigurator
    let shape: ButtonShape
    let state: DSState
    
    public func makeBody(configuration: Configuration) -> some View {
        let contentColor = state == .enabled ? colors.highlightA : colors.highlightA.opacity(constants.disabledOpacity)
        
        configuration.label
            .font(fonts.small)
            .padding(spacings.medium)
            .background(
                buildShapeView(
                    shape,
                    isPressed: configuration.isPressed,
                    fillColor: colors.highlightA.opacity(constants.tapOpacity),
                    strokeColor: contentColor
                )
            )
            .foregroundColor(contentColor)
            .animation(.default, value: configuration.isPressed)
            .allowsHitTesting(state == .enabled)
    }

    
    @ViewBuilder
    private func buildShapeView(_ shapeType: ButtonShape, isPressed: Bool, fillColor: Color, strokeColor: Color) -> some View {
        let shape: AnyShape = {
            switch shapeType {
            case .circle:
                return AnyShape(Circle())
            case .rounded(let radius):
                return AnyShape(RoundedRectangle(cornerRadius: radius))
            }
        }()
        
        shape
            .fill(isPressed ? fillColor : .clear)
            .overlay(
                shape.stroke(strokeColor, lineWidth: 1)
            )
    }

}


public extension ButtonStyle where Self == ContentAButtonStyle {
    static func contentA(
        shape: ButtonShape = .rounded(cornerRadius: .infinity),
        state: DSState = .enabled
    ) -> Self {
        Self(shape: shape, state: state)
    }
}

public extension ButtonStyle where Self == HighlightAButtonStyle {
    static func highlightA(
        shape: ButtonShape = .rounded(cornerRadius: .infinity),
        state: DSState = .enabled
    ) -> Self {
        Self(shape: shape, state: state)
    }
}


public struct CardButtonStyle: ButtonStyle, @preconcurrency BaseThemeDependencies {
    @Dependency(\.themeConfigurator) public var themeConfigurator
    let type: CardType
    let state: DSState
    
    func colors(isPressed: Bool) -> (fillColor: Color, strokeColor: Color, borderedColor: Color) {
        var fillColor = isPressed ? colors.contentA.opacity(constants.tapOpacity) : colors.backgroundB
        var borderedColor = isPressed ? colors.contentA.opacity(constants.tapOpacity) : .clear
        var strokeColor = isPressed ? colors.contentA.opacity(constants.tapOpacity) : colors.contentA
        if state == .disabled {
            fillColor = colors.contentA.opacity(constants.disabledOpacity)
            borderedColor = colors.contentA.opacity(constants.disabledOpacity)
            strokeColor = colors.contentA.opacity(constants.disabledOpacity)
        }
        return (fillColor, strokeColor, borderedColor)
    }
    
    public func makeBody(configuration: Configuration) -> some View {
        let colors = colors(isPressed: configuration.isPressed)
        
        configuration.label
            .background(
                type == .fill ?
                buildShapeView(
                    fillColor: colors.fillColor,
                    strokeColor: .clear
                ) :
                    buildShapeView(
                        fillColor: colors.borderedColor,
                        strokeColor: colors.strokeColor
                    )
            )
            .contentShape(Rectangle())
            .animation(.easeInOut(duration: 0.2), value: configuration.isPressed)
            .allowsHitTesting(state == .enabled)
    }
    
    @ViewBuilder
    private func buildShapeView(fillColor: Color, strokeColor: Color) -> some View {
        let shape: RoundedRectangle = {
            RoundedRectangle(cornerRadius: 24)
        }()
        
        shape
            .fill(fillColor)
            .overlay(
                shape.stroke(strokeColor, lineWidth: 1)
            )
    }
}

public extension ButtonStyle where Self == CardButtonStyle {
    static func cardAppearance(_ type: CardType, state: DSState = .enabled) -> Self { Self(type: type, state: state) }
}

public enum ButtonStyleCase: String, Decodable, Sendable, Identifiable, CaseIterable {
    public var id: String {
        rawValue
    }
    
    case contentA, highlightA, cardAppearanceFill, cardAppearanceBordered
    case contentACircle, highlightACircle
    case highlightADisabled, contentADisabled, cardAppearanceFillDisabled, cardAppearanceBorderedDisabled
    case contentACircleDisabled, highlightACircleDisabled
    
    @MainActor
    public func style(state: DSState = .enabled) -> AnyButtonStyle {
        switch self {
        case .contentA:
            return .init(.contentA(shape: .rounded(cornerRadius: .infinity), state: state))
        case .highlightA:
            return .init(.highlightA(shape: .rounded(cornerRadius: .infinity), state: state))
        case .cardAppearanceFill:
            return .init(.cardAppearance(.fill, state: state))
        case .cardAppearanceBordered:
            return .init(.cardAppearance(.bordered, state: state))
        case .contentADisabled:
            return .init(.contentA(shape: .rounded(cornerRadius: .infinity), state: state))
        case .contentACircle:
            return .init(.contentA(shape: .circle, state: state))
        case .highlightACircle:
            return .init(.highlightA(shape: .circle, state: state))
        case .highlightADisabled:
            return .init(.highlightA(shape: .rounded(cornerRadius: .infinity), state: state))
        case .cardAppearanceFillDisabled:
            return .init(.cardAppearance(.fill, state: state))
        case .cardAppearanceBorderedDisabled:
            return .init(.cardAppearance(.bordered, state: state))
        case .contentACircleDisabled:
            return .init(.contentA(shape: .circle, state: state))
        case .highlightACircleDisabled:
            return .init(.highlightA(shape: .circle, state: state))
        }
    }

}

public enum ButtonShape: Sendable, CaseIterable, Identifiable, Hashable {
    case rounded(cornerRadius: CGFloat)
    case circle
    
    public typealias RawValue = String
    
    public static let allCases: [ButtonShape] = [.circle, .rounded(cornerRadius: 24)]
    
    public var id: String {
        rawValue
    }
    
    public var rawValue: RawValue {
        switch self {
        case .rounded(let cornerRadius):
            return "rounded(\(cornerRadius))"
        case .circle:
            return "circle"
        }
    }
}
