import Dependencies
import SwiftUI
import ZenithCoreInterface

public struct Blur<Content: View>: View {
    @Environment(\.blurStyle) private var style
    
    // O conteúdo a ser exibido sobre o blur
    private let content: Content
    
    // Configurações de blur
    private let blur1Width: CGFloat
    private let blur1Height: CGFloat
    private let blur1Radius: CGFloat
    private let blur1OffsetX: CGFloat
    private let blur1OffsetY: CGFloat
    private let blur1Opacity: Double
    
    private let blur2Width: CGFloat
    private let blur2Height: CGFloat
    private let blur2Radius: CGFloat
    private let blur2OffsetX: CGFloat
    private let blur2OffsetY: CGFloat
    private let blur2Opacity: Double
    
    private let blur3Width: CGFloat
    private let blur3Height: CGFloat
    private let blur3Radius: CGFloat
    private let blur3OffsetX: CGFloat
    private let blur3OffsetY: CGFloat
    private let blur3Opacity: Double
    
    private let cornerRadius: CGFloat
    
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
        
        self.cornerRadius = cornerRadius
        
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
    }
    
    public var body: some View {
        AnyView(
            style.resolve(
                configuration: BlurStyleConfiguration(
                    content: AnyView(content),
                    
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
            )
        )
    }
}
