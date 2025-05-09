import Dependencies
import SwiftUI
import ZenithCoreInterface

public struct CircularProgress: View {
    @Environment(\.circularprogressStyle) private var style
    
    let text: String
    let progress: Double
    let size: CGFloat
    let showText: Bool
    let animated: Bool
    
    @State private var animatedProgress: Double
    @State private var isAnimating: Bool = false
    
    public init(
        text: String = "",
        progress: Double,
        size: CGFloat = 60,
        showText: Bool = true,
        animated: Bool = false
    ) {
        self.text = text
        self.progress = progress
        self.size = size
        self.showText = showText
        self.animated = animated
        self._animatedProgress = State(initialValue: progress)
    }
    
    public var body: some View {
        AnyView(
            style.resolve(
                configuration: CircularProgressStyleConfiguration(
                    text: text,
                    progress: animated ? animatedProgress : progress,
                    size: size,
                    showText: showText,
                    isAnimating: isAnimating,
                    animated: animated
                )
            )
        )
        .onChange(of: progress) { newValue in
            guard animated else { return }
            
            withAnimation(.easeInOut(duration: 0.8)) {
                isAnimating = true
                animatedProgress = newValue
            }
            
            // Desativa o estado de animação após a conclusão
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.9) {
                isAnimating = false
            }
        }
        .onAppear {
            guard animated else { return }
            
            // Inicialmente anima para o valor inicial quando o componente aparece
            withAnimation(.easeInOut(duration: 0.5)) {
                animatedProgress = progress
            }
        }
    }
}
