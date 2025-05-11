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
    static func `default`(_ colorName: ColorName) -> Self { .init(colorName: colorName) }
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
            .init(.default(colorName))
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
            RoundedRectangle(cornerRadius: configuration.blurConfig.cornerRadius)
                .fill(color.opacity(0.5))
                .frame(width: configuration.blurConfig.blur3Width, height: configuration.blurConfig.blur3Height)
                .blur(radius: configuration.blurConfig.blur3Radius)
                .offset(x: configuration.blurConfig.blur3OffsetX, y: configuration.blurConfig.blur3OffsetY)
                .opacity(configuration.blurConfig.blur3Opacity)
            
            // Segunda camada de blur (média)
            RoundedRectangle(cornerRadius: configuration.blurConfig.cornerRadius)
                .fill(color.opacity(0.5))
                .frame(width: configuration.blurConfig.blur2Width, height: configuration.blurConfig.blur2Height)
                .blur(radius: configuration.blurConfig.blur2Radius)
                .offset(x: configuration.blurConfig.blur2OffsetX, y: configuration.blurConfig.blur2OffsetY)
                .opacity(configuration.blurConfig.blur2Opacity)
            
            // Primeira camada de blur (menor e mais próxima)
            RoundedRectangle(cornerRadius: configuration.blurConfig.cornerRadius)
                .fill(color.opacity(0.7))
                .frame(width: configuration.blurConfig.blur1Width, height: configuration.blurConfig.blur1Height)
                .blur(radius: configuration.blurConfig.blur1Radius)
                .offset(x: configuration.blurConfig.blur1OffsetX, y: configuration.blurConfig.blur1OffsetY)
                .opacity(configuration.blurConfig.blur1Opacity)
            
            configuration.content
        }
        .mask(
            // Esta máscara garante que o blur respeite as bordas arredondadas
            RoundedRectangle(cornerRadius: configuration.blurConfig.cornerRadius)
                .fill(Color.white)
        )
    }
}
