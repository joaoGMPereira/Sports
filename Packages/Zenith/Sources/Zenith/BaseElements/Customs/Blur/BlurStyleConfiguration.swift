import SwiftUI
import ZenithCoreInterface

/// Protocolo para identificar structs genericamente
public protocol AnyStruct {}
public extension AnyStruct where Self: Decodable {}

// Configuração compartilhada de blur que pode ser usada por diferentes componentes
public struct BlurConfig: Sendable, Equatable, AnyStruct {
    // Primeira camada de blur (menor e mais próxima)
    public let blur1Width: CGFloat
    public let blur1Height: CGFloat
    public let blur1Radius: CGFloat
    public let blur1OffsetX: CGFloat
    public let blur1OffsetY: CGFloat
    public let blur1Opacity: Double
    
    // Segunda camada de blur (média)
    public let blur2Width: CGFloat
    public let blur2Height: CGFloat
    public let blur2Radius: CGFloat
    public let blur2OffsetX: CGFloat
    public let blur2OffsetY: CGFloat
    public let blur2Opacity: Double
    
    // Terceira camada de blur (maior e mais suave)
    public let blur3Width: CGFloat
    public let blur3Height: CGFloat
    public let blur3Radius: CGFloat
    public let blur3OffsetX: CGFloat
    public let blur3OffsetY: CGFloat
    public let blur3Opacity: Double
    
    // Configuração geral
    public let cornerRadius: CGFloat
    
    public init(
        blur1Width: CGFloat = 42,
        blur1Height: CGFloat = 24,
        blur1Radius: CGFloat = 20,
        blur1OffsetX: CGFloat = -25,
        blur1OffsetY: CGFloat = 25,
        blur1Opacity: Double = 0.9,
        
        blur2Width: CGFloat = 80,
        blur2Height: CGFloat = 40,
        blur2Radius: CGFloat = 40,
        blur2OffsetX: CGFloat = -20,
        blur2OffsetY: CGFloat = 20,
        blur2Opacity: Double = 1.0,
        
        blur3Width: CGFloat = 100,
        blur3Height: CGFloat = 50,
        blur3Radius: CGFloat = 50,
        blur3OffsetX: CGFloat = -20,
        blur3OffsetY: CGFloat = 20,
        blur3Opacity: Double = 1.0,
        
        cornerRadius: CGFloat = 20
    ) {
        self.blur1Width = blur1Width
        self.blur1Height = blur1Height
        self.blur1Radius = blur1Radius
        self.blur1OffsetX = blur1OffsetX
        self.blur1OffsetY = blur1OffsetY
        self.blur1Opacity = blur1Opacity
        
        self.blur2Width = blur2Width
        self.blur2Height = blur2Height
        self.blur2Radius = blur2Radius
        self.blur2OffsetX = blur2OffsetX
        self.blur2OffsetY = blur2OffsetY
        self.blur2Opacity = blur2Opacity
        
        self.blur3Width = blur3Width
        self.blur3Height = blur3Height
        self.blur3Radius = blur3Radius
        self.blur3OffsetX = blur3OffsetX
        self.blur3OffsetY = blur3OffsetY
        self.blur3Opacity = blur3Opacity
        
        self.cornerRadius = cornerRadius
    }
    
    // Métodos de fábrica para configurações comuns
    public static func standard() -> BlurConfig {
        return BlurConfig()
    }
    
    public static func subtle() -> BlurConfig {
        return BlurConfig(
            blur1Radius: 10,
            blur1Opacity: 0.7,
            blur2Radius: 20,
            blur2Opacity: 0.8,
            blur3Radius: 30,
            blur3Opacity: 0.9
        )
    }
    
    public static func intense() -> BlurConfig {
        return BlurConfig(
            blur1Radius: 30,
            blur1Opacity: 0.95,
            blur2Radius: 60,
            blur2Opacity: 0.9,
            blur3Radius: 80,
            blur3Opacity: 0.85
        )
    }
}

public struct AnyBlurStyle: BlurStyle & Sendable & Identifiable {
    public let id: UUID = .init()
    
    private let _makeBody: @Sendable (BlurStyleConfiguration) -> AnyView
    
    public init<S: BlurStyle>(_ style: S) {
        _makeBody = { @Sendable configuration in
            AnyView(style.makeBody(configuration: configuration))
        }
    }
    
    public func makeBody(configuration: BlurStyleConfiguration) -> some View {
        _makeBody(configuration)
    }
}

public protocol BlurStyle: StyleProtocol & Identifiable {
    typealias Configuration = BlurStyleConfiguration
}

public struct BlurStyleConfiguration {
    let content: AnyView
    let blurConfig: BlurConfig
    
    init(
        content: AnyView,
        blurConfig: BlurConfig = .standard()
    ) {
        self.content = content
        self.blurConfig = blurConfig
    }
}

public struct BlurStyleKey: EnvironmentKey {
    public static let defaultValue: any BlurStyle = DefaultBlurStyle(colorName: .highlightA)
}

public extension EnvironmentValues {
    var blurStyle : any BlurStyle {
        get { self[BlurStyleKey.self] }
        set { self[BlurStyleKey.self] = newValue }
    }
}

public extension BlurStyle {
    @MainActor
    func resolve(configuration: Configuration) -> some View {
        ResolvedBlurStyle(style: self, configuration: configuration)
    }
}

private struct ResolvedBlurStyle<Style: BlurStyle>: View {
    let style: Style
    let configuration: Style.Configuration
    
    var body: some View {
        style.makeBody(configuration: configuration)
    }
}
