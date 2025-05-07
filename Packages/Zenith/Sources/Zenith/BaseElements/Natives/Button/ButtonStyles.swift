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

// Protocolo para compartilhar métodos comuns entre estilos de botão
protocol SharedButtonStyleMethods {
    associatedtype Content: View
    func buildShapeView(for shape: ButtonShape, isPressed: Bool, pressColor: Color, fillColor: Color, strokeColor: Color) -> Content
}

extension SharedButtonStyleMethods {
    @ViewBuilder
    func buildShapeView(for shapeType: ButtonShape, isPressed: Bool, pressColor: Color, fillColor: Color = .clear, strokeColor: Color) -> some View {
        let shape: AnyShape = {
            switch shapeType {
            case .circle:
                return AnyShape(Circle())
            case .rounded(let radius):
                return AnyShape(RoundedRectangle(cornerRadius: radius))
            }
        }()
        
        shape
            .fill(isPressed ? pressColor : fillColor)
            .overlay(
                shape.stroke(strokeColor, lineWidth: 1)
            )
    }
}

public struct ContentAButtonStyle: ButtonStyle, @preconcurrency BaseThemeDependencies, SharedButtonStyleMethods {
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
                    for: shape,
                    isPressed: configuration.isPressed,
                    pressColor: colors.contentA.opacity(constants.tapOpacity),
                    strokeColor: contentColor
                )
            )
            .foregroundColor(contentColor)
            .animation(.default, value: configuration.isPressed)
            .allowsHitTesting(state == .enabled)
    }
}

public struct HighlightAButtonStyle: ButtonStyle, @preconcurrency BaseThemeDependencies, SharedButtonStyleMethods {
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
                    for: shape,
                    isPressed: configuration.isPressed,
                    pressColor: colors.highlightA.opacity(constants.tapOpacity),
                    strokeColor: contentColor
                )
            )
            .foregroundColor(contentColor)
            .animation(.default, value: configuration.isPressed)
            .allowsHitTesting(state == .enabled)
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

public struct BackgroundDButtonStyle: ButtonStyle, @preconcurrency BaseThemeDependencies, SharedButtonStyleMethods {
    @Dependency(\.themeConfigurator) public var themeConfigurator
    
    let shape: ButtonShape
    let state: DSState
    
    public func makeBody(configuration: Configuration) -> some View {
        let contentColor = state == .enabled ? colors.contentA : colors.contentA.opacity(constants.disabledOpacity)
        let disabledColor = colors.backgroundD.opacity(constants.disabledOpacity)
        let backgroundColor = state == .enabled ? colors.backgroundD : disabledColor
        
        configuration
            .label
            .font(fonts.small)
            .padding(spacings.medium)
            .background(
                buildShapeView(
                    for: shape,
                    isPressed: configuration.isPressed,
                    pressColor: disabledColor,
                    fillColor: backgroundColor,
                    strokeColor: .clear
                )
            )
            .foregroundColor(contentColor)
            .animation(.default, value: configuration.isPressed)
            .allowsHitTesting(state == .enabled)
    }
}

public extension ButtonStyle where Self == BackgroundDButtonStyle {
    static func backgroundD(
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
    
    func colors(isPressed: Bool, type: CardType) -> (fillColor: Color, strokeColor: Color) {
        if type == .fill {
            var fillColor = isPressed ? colors.contentA.opacity(constants.tapOpacity) : colors.backgroundD
            var strokeColor = constants.strokeColor.opacity(isPressed ? constants.tapOpacity : 1)
            if state == .disabled {
                fillColor = colors.backgroundD.opacity(constants.disabledOpacity)
                strokeColor = constants.strokeColor.opacity(constants.disabledOpacity)
            }
            return (fillColor, strokeColor)
        } else {
            var fillColor = isPressed ? colors.contentC.opacity(constants.tapOpacity) : .clear
            var strokeColor = isPressed ? colors.contentC.opacity(constants.tapOpacity) : colors.contentA
            if state == .disabled {
                fillColor = colors.contentA.opacity(constants.disabledOpacity)
                strokeColor = colors.contentA.opacity(constants.disabledOpacity)
            }
            return (fillColor, strokeColor)
        }
    }
    
    public func makeBody(configuration: Configuration) -> some View {
        let colors = colors(isPressed: configuration.isPressed, type: type)
        
        configuration.label
            .background(
                buildShapeView(
                    fillColor: colors.fillColor,
                    strokeColor: colors.strokeColor
                )
            )
            .contentShape(Rectangle())
            .animation(.easeInOut(duration: 0.2), value: configuration.isPressed)
            .allowsHitTesting(state == .enabled)
    }
    
    @ViewBuilder
    private func buildShapeView(fillColor: Color, strokeColor: Color) -> some View {
        let shape = RoundedRectangle(cornerRadius: constants.cornerRadius)
        
        shape
            .fill(fillColor)
            .overlay(
                shape.stroke(strokeColor, lineWidth: 0.4)
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
    case backgroundD, backgroundDCircle, backgroundDDisabled, backgroundDCircleDisabled
    
    @MainActor
    public func style() -> AnyButtonStyle {
        switch self {
        case .contentA:
            return .init(.contentA(shape: .rounded(cornerRadius: .infinity), state: .enabled))
        case .highlightA:
            return .init(.highlightA(shape: .rounded(cornerRadius: .infinity), state: .enabled))
        case .cardAppearanceFill:
            return .init(.cardAppearance(.fill, state: .enabled))
        case .cardAppearanceBordered:
            return .init(.cardAppearance(.bordered, state: .enabled))
        case .contentADisabled:
            return .init(.contentA(shape: .rounded(cornerRadius: .infinity), state: .disabled))
        case .contentACircle:
            return .init(.contentA(shape: .circle, state: .enabled))
        case .highlightACircle:
            return .init(.highlightA(shape: .circle, state: .enabled))
        case .highlightADisabled:
            return .init(.highlightA(shape: .rounded(cornerRadius: .infinity), state: .disabled))
        case .cardAppearanceFillDisabled:
            return .init(.cardAppearance(.fill, state: .disabled))
        case .cardAppearanceBorderedDisabled:
            return .init(.cardAppearance(.bordered, state: .disabled))
        case .contentACircleDisabled:
            return .init(.contentA(shape: .circle, state: .disabled))
        case .highlightACircleDisabled:
            return .init(.highlightA(shape: .circle, state: .disabled))
        case .backgroundD:
            return .init(.backgroundD(shape: .rounded(cornerRadius: .infinity), state: .enabled))
        case .backgroundDCircle:
            return .init(.backgroundD(shape: .circle, state: .enabled))
        case .backgroundDDisabled:
            return .init(.backgroundD(shape: .rounded(cornerRadius: .infinity), state: .disabled))
        case .backgroundDCircleDisabled:
            return .init(.backgroundD(shape: .circle, state: .disabled))
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
