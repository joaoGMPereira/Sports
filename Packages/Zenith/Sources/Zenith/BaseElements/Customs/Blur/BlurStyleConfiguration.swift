import SwiftUI
import ZenithCoreInterface

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
    
    // Primeira camada de blur (menor e mais próxima)
    let blur1Width: CGFloat
    let blur1Height: CGFloat
    let blur1Radius: CGFloat
    let blur1OffsetX: CGFloat
    let blur1OffsetY: CGFloat
    let blur1Opacity: Double
    
    // Segunda camada de blur (média)
    let blur2Width: CGFloat
    let blur2Height: CGFloat
    let blur2Radius: CGFloat
    let blur2OffsetX: CGFloat
    let blur2OffsetY: CGFloat
    let blur2Opacity: Double
    
    // Terceira camada de blur (maior e mais suave)
    let blur3Width: CGFloat
    let blur3Height: CGFloat
    let blur3Radius: CGFloat
    let blur3OffsetX: CGFloat
    let blur3OffsetY: CGFloat
    let blur3Opacity: Double
    
    // Configuração geral
    let cornerRadius: CGFloat
    
    init(
        content: AnyView,
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
        self.content = content
        
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
