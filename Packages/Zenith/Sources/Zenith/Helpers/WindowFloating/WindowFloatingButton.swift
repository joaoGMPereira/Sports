import SwiftUI
import ZenithCoreInterface

/// View modifier para adicionar funcionalidade de flutuação na Window para qualquer View
public struct WindowFloatingButtonModifier<ButtonContent: View>: ViewModifier {
    @Binding var isFloating: Bool
    let backgroundColor: Color
    let buttonContent: ButtonContent
    
    public init(
        isFloating: Binding<Bool>,
        backgroundColor: Color,
        @ViewBuilder buttonContent: () -> ButtonContent
    ) {
        self._isFloating = isFloating
        self.backgroundColor = backgroundColor
        self.buttonContent = buttonContent()
    }
    
    public func body(content: Content) -> some View {
        content
            // Adicionamos o view modifier de janela flutuante
            .windowFloatingView(isPresented: $isFloating, backgroundColor: backgroundColor) {
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
    ///   - isDraggable: Se a view pode ser arrastada
    ///   - backgroundColor: Cor de fundo do card flutuante
    ///   - buttonContent: Conteúdo personalizado para exibir no botão flutuante
    func makeWindowFloating<ButtonContent: View>(
        isFloating: Binding<Bool>,
        backgroundColor: Color,
        @ViewBuilder buttonContent: @escaping () -> ButtonContent
    ) -> some View {
        modifier(
            WindowFloatingButtonModifier(
                isFloating: isFloating,
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
    ///   - isDraggable: Se a view pode ser arrastada
    ///   - backgroundColor: Cor de fundo do card flutuante
    func makeWindowFloating(
        isFloating: Binding<Bool>,
        backgroundColor: Color
    ) -> some View {
        makeWindowFloating(
            isFloating: isFloating,
            backgroundColor: backgroundColor
        ) {
            self
        }
    }
}
