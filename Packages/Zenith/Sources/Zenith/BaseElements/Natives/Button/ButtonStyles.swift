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

public struct PrimaryButtonStyle: ButtonStyle, @preconcurrency BaseThemeDependencies {
    @Dependency(\.themeConfigurator) public var themeConfigurator
    public var shape: ButtonShape = .rounded(cornerRadius: .infinity)
    
    public func makeBody(configuration: Configuration) -> some View {
        configuration
            .label
            .font(fonts.small)
            .padding(spacings.medium)
            .background(
                buildShapeView(
                    shape,
                    isPressed: configuration.isPressed,
                    fillColor: colors.textPrimary.opacity(constants.tapOpacity),
                    strokeColor: colors.textPrimary
                )
            )
            .foregroundColor(colors.textPrimary)
            .animation(.default, value: configuration.isPressed)
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


public extension ButtonStyle where Self == PrimaryButtonStyle {
    static var primary: Self { Self() }
}

public struct HighlightAButtonStyle: ButtonStyle, @preconcurrency BaseThemeDependencies {
    @Dependency(\.themeConfigurator) public var themeConfigurator
    let shape: ButtonShape
    
    public init(shape: ButtonShape = .rounded(cornerRadius: .infinity)) {
        self.shape = shape
    }
    
    public func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(fonts.small)
            .padding(spacings.medium)
            .background(
                buildShapeView(
                    shape,
                    isPressed: configuration.isPressed,
                    fillColor: colors.highlightA.opacity(constants.tapOpacity),
                    strokeColor: colors.highlightA
                )
            )
            .foregroundColor(colors.highlightA)
            .animation(.default, value: configuration.isPressed)
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


public extension ButtonStyle where Self == PrimaryButtonStyle {
    static func primary(shape: ButtonShape = .rounded(cornerRadius: .infinity)) -> Self {
        Self(shape: shape)
    }
}

public extension ButtonStyle where Self == HighlightAButtonStyle {
    static func highlightA(shape: ButtonShape = .rounded(cornerRadius: .infinity)) -> Self {
        Self(shape: shape)
    }
}


public struct CardButtonStyle: ButtonStyle, @preconcurrency BaseThemeDependencies {
    @Dependency(\.themeConfigurator) public var themeConfigurator
    let type: CardType
    
    public func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .background(
                type == .fill
                ?
                RoundedRectangle(cornerRadius: 24)// TODO RADIUS
                    .fill(configuration.isPressed ? colors.textPrimary.opacity(constants.tapOpacity) : colors.backgroundSecondary)
                :
                RoundedRectangle(cornerRadius: 24)// TODO RADIUS
                    .fill(configuration.isPressed ? colors.textPrimary.opacity(constants.tapOpacity) : .clear)
            )
            .contentShape(Rectangle())
            .animation(.easeInOut(duration: 0.2), value: configuration.isPressed)
    }
}

public extension ButtonStyle where Self == CardButtonStyle {
    static func cardAppearance(_ type: CardType) -> Self { Self(type: type) }
}

public enum ButtonStyleCase: String, Decodable, Sendable, Identifiable, CaseIterable {
    public var id: String {
        rawValue
    }
    
    case primary, highlightA, cardAppearanceFill, cardAppearanceBordered
    
    @MainActor
    public func style(shape: ButtonShape = .rounded(cornerRadius: .infinity)) -> AnyButtonStyle {
        switch self {
        case .primary:
            return .init(.primary(shape: shape))
        case .highlightA:
            return .init(.highlightA(shape: shape))
        case .cardAppearanceFill:
            return .init(.cardAppearance(.fill))
        case .cardAppearanceBordered:
            return .init(.cardAppearance(.bordered))
        }
    }

}

public enum ButtonShape {
    case rounded(cornerRadius: CGFloat)
    case circle
}
