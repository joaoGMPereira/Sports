import SwiftUI
import ZenithCoreInterface

/// View modifier para adicionar funcionalidade de flutuação na Window para qualquer View
public struct WindowFloatingButtonModifier<ButtonContent: View>: ViewModifier {
    @Binding var isFloating: Bool
    let scale: CGFloat
    let backgroundOpacity: Double
    let backgroundBlur: Double
    let showCloseButton: Bool
    let isDraggable: Bool
    let backgroundColor: Color
    let buttonContent: ButtonContent
    
    public init(
        isFloating: Binding<Bool>,
        scale: CGFloat = 1.05,
        backgroundOpacity: Double = 0.6,
        backgroundBlur: Double = 5,
        showCloseButton: Bool = true,
        isDraggable: Bool = true,
        backgroundColor: Color,
        @ViewBuilder buttonContent: () -> ButtonContent
    ) {
        self._isFloating = isFloating
        self.scale = scale
        self.backgroundOpacity = backgroundOpacity
        self.backgroundBlur = backgroundBlur
        self.showCloseButton = showCloseButton
        self.isDraggable = isDraggable
        self.backgroundColor = backgroundColor
        self.buttonContent = buttonContent()
    }
    
    public func body(content: Content) -> some View {
        content
            // Efeito de escala quando pressionado
            .scaleEffect(isFloating ? scale : 1.0)
            // Adicionamos o view modifier de janela flutuante
            .windowFloatingView(isPresented: $isFloating, isDraggable: isDraggable, backgroundColor: backgroundColor) {
                ZStack {
                    // Conteúdo flutuante - o botão X agora é gerenciado pelo FloatingWindowWrapper
                    buttonContent
                }
                .padding(10)
            }
    }
}

// Extensão para adicionar o método ao View
public extension View {
    /// Torna uma view flutuante, anexada diretamente à Window do aplicativo
    /// - Parameters:
    ///   - isFloating: Binding que controla se a view está flutuando
    ///   - scale: Fator de escala quando flutuando
    ///   - backgroundOpacity: Opacidade do fundo
    ///   - backgroundBlur: Intensidade do blur no fundo
    ///   - showCloseButton: Se deve mostrar um botão para fechar
    ///   - isDraggable: Se a view pode ser arrastada
    ///   - backgroundColor: Cor de fundo do card flutuante
    ///   - buttonContent: Conteúdo personalizado para exibir no botão flutuante
    func makeWindowFloating<ButtonContent: View>(
        isFloating: Binding<Bool>,
        scale: CGFloat = 1.05,
        backgroundOpacity: Double = 0.6,
        backgroundBlur: Double = 5,
        showCloseButton: Bool = true,
        isDraggable: Bool = true,
        backgroundColor: Color,
        @ViewBuilder buttonContent: @escaping () -> ButtonContent
    ) -> some View {
        modifier(
            WindowFloatingButtonModifier(
                isFloating: isFloating,
                scale: scale,
                backgroundOpacity: backgroundOpacity,
                backgroundBlur: backgroundBlur,
                showCloseButton: showCloseButton,
                isDraggable: isDraggable,
                backgroundColor: backgroundColor,
                buttonContent: buttonContent
            )
        )
    }
    
    /// Torna a view atual flutuante, anexada diretamente à Window do aplicativo
    /// - Parameters:
    ///   - isFloating: Binding que controla se a view está flutuando
    ///   - scale: Fator de escala quando flutuando
    ///   - backgroundOpacity: Opacidade do fundo
    ///   - backgroundBlur: Intensidade do blur no fundo
    ///   - showCloseButton: Se deve mostrar um botão para fechar
    ///   - isDraggable: Se a view pode ser arrastada
    ///   - backgroundColor: Cor de fundo do card flutuante
    func makeWindowFloating(
        isFloating: Binding<Bool>,
        scale: CGFloat = 1.05,
        backgroundOpacity: Double = 0.6,
        backgroundBlur: Double = 5,
        showCloseButton: Bool = true,
        isDraggable: Bool = true,
        backgroundColor: Color
    ) -> some View {
        makeWindowFloating(
            isFloating: isFloating,
            scale: scale,
            backgroundOpacity: backgroundOpacity,
            backgroundBlur: backgroundBlur,
            showCloseButton: showCloseButton,
            isDraggable: isDraggable,
            backgroundColor: backgroundColor
        ) {
            self
        }
    }
}
