import Dependencies
import SwiftUI
import ZenithCoreInterface

public struct Blur<Content: View>: View {
    @Environment(\.blurStyle) private var style
    
    // Conteúdo da View
    let content: Content
    // Configuração de blur
    let blurConfig: BlurConfig
    
    public init(
        blurConfig: BlurConfig = .standard(),
        @ViewBuilder content: () -> Content
    ) {
        self.content = content()
        self.blurConfig = blurConfig
    }
    
    // Inicializador com parâmetros separados mantido para compatibilidade
    public init(
        cornerRadius: CGFloat = 20,
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
        @ViewBuilder content: () -> Content
    ) {
        self.content = content()
        
        // Usa BlurConfig internamente
        self.blurConfig = BlurConfig(
            blur1Width: blur1Width,
            blur1Height: blur1Height,
            blur1Radius: blur1Radius,
            blur1OffsetX: blur1OffsetX,
            blur1OffsetY: blur1OffsetY,
            blur1Opacity: blur1Opacity,
            
            blur2Width: blur2Width,
            blur2Height: blur2Height,
            blur2Radius: blur2Radius,
            blur2OffsetX: blur2OffsetX,
            blur2OffsetY: blur2OffsetY,
            blur2Opacity: blur2Opacity,
            
            blur3Width: blur3Width,
            blur3Height: blur3Height,
            blur3Radius: blur3Radius,
            blur3OffsetX: blur3OffsetX,
            blur3OffsetY: blur3OffsetY,
            blur3Opacity: blur3Opacity,
            
            cornerRadius: cornerRadius
        )
    }
    
    // Inicializador de conveniência para texto simples
    public init(
        _ text: String,
        cornerRadius: CGFloat = 20,
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
        blur3Opacity: Double = 1.0
    ) where Content == Text {
        self.content = Text(text)
        
        // Usa BlurConfig internamente
        self.blurConfig = BlurConfig(
            blur1Width: blur1Width,
            blur1Height: blur1Height,
            blur1Radius: blur1Radius,
            blur1OffsetX: blur1OffsetX,
            blur1OffsetY: blur1OffsetY,
            blur1Opacity: blur1Opacity,
            
            blur2Width: blur2Width,
            blur2Height: blur2Height,
            blur2Radius: blur2Radius,
            blur2OffsetX: blur2OffsetX,
            blur2OffsetY: blur2OffsetY,
            blur2Opacity: blur2Opacity,
            
            blur3Width: blur3Width,
            blur3Height: blur3Height,
            blur3Radius: blur3Radius,
            blur3OffsetX: blur3OffsetX,
            blur3OffsetY: blur3OffsetY,
            blur3Opacity: blur3Opacity,
            
            cornerRadius: cornerRadius
        )
    }
    
    // Inicializador simples para texto com BlurConfig
    public init(
        _ text: String,
        blurConfig: BlurConfig = .standard()
    ) where Content == Text {
        self.content = Text(text)
        self.blurConfig = blurConfig
    }
    
    public var body: some View {
        AnyView(
            style.resolve(
                configuration: BlurStyleConfiguration(
                    content: AnyView(content),
                    blurConfig: blurConfig
                )
            )
        )
    }
}
