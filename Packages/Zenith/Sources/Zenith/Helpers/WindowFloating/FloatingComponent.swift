import SwiftUI

/// View flutuante que aparece sobre o conteúdo da aplicação
public struct FloatingComponent: View {
    /// Estado global compartilhado
    @ObservedObject private var state = FloatingComponentState.shared
    
    /// Estado de arrasto
    @State private var dragOffset = CGSize.zero
    @State private var position = CGPoint(x: UIScreen.main.bounds.midX, y: UIScreen.main.bounds.midY)
    
    public init() {}
    
    public var body: some View {
        GeometryReader { geometry in
            ZStack {
                // Fundo semi-transparente quando o componente está visível
                if state.isVisible {
                    
                    // Componente flutuante com o conteúdo atual
                    if let content = state.content {
                        componentView(content: content)
                            .id(state.updateCounter) // Forçar recriação quando o contador mudar
                    }
                }
            }
        }
        .animation(.spring(response: 0.3, dampingFraction: 0.8), value: state.isVisible)
    }
    
    /// Cria a view do componente flutuante
    private func componentView(content: AnyView) -> some View {
        ZStack(alignment: .topTrailing) {
            // Conteúdo principal
            content
                .padding()
                .allowsHitTesting(false)
            
            // Botão para fechar
            Button(action: {
                withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                    state.hide()
                }
            }) {
                Image(systemName: "xmark.circle.fill")
                    .font(.system(size: 22))
                    .foregroundColor(.gray)
                    .padding(8)
            }
        }
        .padding(8)
        .background(state.backgroundColor)
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.3), radius: 10, x: 0, y: 5)
        .offset(x: dragOffset.width, y: dragOffset.height)
        .position(x: position.x, y: position.y)
        .gesture(
            DragGesture()
                .onChanged { value in
                    self.dragOffset = value.translation
                }
                .onEnded { value in
                    // Atualiza a posição final e reseta o offset
                    self.position = CGPoint(
                        x: self.position.x + value.translation.width,
                        y: self.position.y + value.translation.height
                    )
                    self.dragOffset = .zero
                }
        )
        .transition(.scale(scale: 0.9).combined(with: .opacity))
        .zIndex(999) // Garante que fique acima de tudo
    }
}
