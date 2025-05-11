import Dependencies
import SwiftUI
import ZenithCoreInterface

public struct CircularProgress: View {
    @Environment(\.circularProgressStyle) private var style
    
    private let configuration: CircularProgressStyleConfiguration
    @State private var animatedProgress: Double
    @State private var isAnimating: Bool
    
    // Inicializador com configuração completa
    public init(configuration: CircularProgressStyleConfiguration) {
        self.configuration = configuration
        self._animatedProgress = State(initialValue: configuration.progress)
        self._isAnimating = State(initialValue: configuration.isAnimating)
    }
    
    // Inicializador com parâmetros individuais que cria uma configuração
    public init(
        text: String = "",
        progress: Double,
        size: CGFloat = 54,
        showText: Bool = true,
        animated: Bool = false
    ) {
        let config = CircularProgressStyleConfiguration(
            text: text,
            progress: progress,
            size: size,
            showText: showText,
            isAnimating: false,
            animated: animated
        )
        self.configuration = config
        self._animatedProgress = State(initialValue: progress)
        self._isAnimating = State(initialValue: false)
    }
    
    public var body: some View {
        AnyView(
            style.resolve(
                configuration: configuration.animated 
                    ? CircularProgressStyleConfiguration(
                        text: configuration.text,
                        progress: animatedProgress,
                        size: configuration.size,
                        showText: configuration.showText,
                        isAnimating: isAnimating,
                        animated: configuration.animated
                      )
                    : configuration
            )
        )
        .onChange(of: configuration.progress) { newValue in
            guard configuration.animated else { return }
            
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
            guard configuration.animated else { return }
            
            // Inicialmente anima para o valor inicial quando o componente aparece
            withAnimation(.easeInOut(duration: 0.5)) {
                animatedProgress = configuration.progress
            }
        }
    }
}
