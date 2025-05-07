import SwiftUI
import ZenithCoreInterface


public extension View {
    func blurStyle(_ style: some BlurStyle) -> some View {
        environment(\.blurStyle, style)
    }
}

public struct DefaultBlurStyle: @preconcurrency BlurStyle, BaseThemeDependencies {
    public var id = String(describing: Self.self)
    
    @Dependency(\.themeConfigurator) public var themeConfigurator
    
    private let colorName: ColorName
    
    public init(colorName: ColorName) {
        self.colorName = colorName
    }
    
    @MainActor
    public func makeBody(configuration: Configuration) -> some View {
        BaseBlur(
            configuration: configuration,
            color: colors.color(by: colorName) ?? .gray
        )
    }
}

public extension BlurStyle where Self == DefaultBlurStyle {
    static func `default`(colorName: ColorName) -> Self { .init(colorName: colorName) }
}

public enum BlurStyleCase: Identifiable {
    case `default`(ColorName)
    
    public var id: String {
        switch self {
        case .default(let colorName):
            return "default_\(colorName.rawValue)"
        }
    }
    
    public static var allCases: [BlurStyleCase] {
        var cases: [BlurStyleCase] = []
        ColorName.allCases.forEach { colorName in
            cases.append(.default(colorName))
        }
        return cases
    }
    
    public func style() -> AnyBlurStyle {
        switch self {
        case .default(let colorName):
            .init(.default(colorName: colorName))
        }
    }
    
    public var description: String {
        switch self {
        case .default(let colorName):
            return colorName.rawValue
        }
    }
}

private struct BaseBlur: View, @preconcurrency BaseThemeDependencies {
    @Dependency(\.themeConfigurator) public var themeConfigurator: any ThemeConfiguratorProtocol
    
    let configuration: BlurStyleConfiguration
    let color: Color
    
    var body: some View {
        ZStack(alignment: .topTrailing) {
            // Terceira camada de blur (maior e mais suave)
            RoundedRectangle(cornerRadius: configuration.cornerRadius)
                .fill(color.opacity(0.5))
                .frame(width: configuration.blur3Width, height: configuration.blur3Height)
                .blur(radius: configuration.blur3Radius)
                .offset(x: configuration.blur3OffsetX, y: configuration.blur3OffsetY)
                .opacity(configuration.blur3Opacity)
            
            // Segunda camada de blur (média)
            RoundedRectangle(cornerRadius: configuration.cornerRadius)
                .fill(color.opacity(0.5))
                .frame(width: configuration.blur2Width, height: configuration.blur2Height)
                .blur(radius: configuration.blur2Radius)
                .offset(x: configuration.blur2OffsetX, y: configuration.blur2OffsetY)
                .opacity(configuration.blur2Opacity)
            
            // Primeira camada de blur (menor e mais próxima)
            RoundedRectangle(cornerRadius: configuration.cornerRadius)
                .fill(color.opacity(0.7))
                .frame(width: configuration.blur1Width, height: configuration.blur1Height)
                .blur(radius: configuration.blur1Radius)
                .offset(x: configuration.blur1OffsetX, y: configuration.blur1OffsetY)
                .opacity(configuration.blur1Opacity)
            
            configuration.content
        }
        .mask(
            // Esta máscara garante que o blur respeite as bordas arredondadas
            RoundedRectangle(cornerRadius: configuration.cornerRadius)
                .fill(Color.white)
        )
    }
}
