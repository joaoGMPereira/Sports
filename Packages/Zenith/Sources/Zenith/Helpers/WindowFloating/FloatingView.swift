import SwiftUI

/// View flutuante que aparece sobreposta à aplicação
public struct FloatingView<Content: View>: View {
    /// Ambiente para acessar o estado da view flutuante
    @Environment(\.floatingViewState) private var floatingViewState
    
    /// Conteúdo a ser exibido na view flutuante
    let content: Content
    
    /// Cor de fundo da view
    let backgroundColor: Color
    
    /// Estado de arrasto
    @State private var dragOffset = CGSize.zero
    @State private var position = CGPoint(x: UIScreen.main.bounds.midX, y: UIScreen.main.bounds.midY)
    
    /// ID para forçar recriação quando updateCounter muda
    @ObservedObject private var updateTracker: FloatingViewState
    
    init(content: Content, backgroundColor: Color, updateTracker: FloatingViewState) {
        self.content = content
        self.backgroundColor = backgroundColor
        self.updateTracker = updateTracker
    }
    
    public var body: some View {
        ZStack(alignment: .topTrailing) {
            // Conteúdo principal
            content
                .padding()
                .allowsHitTesting(false)
            
            // Botão para fechar
            Button(action: {
                withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                    floatingViewState.dismiss()
                }
            }) {
                Image(systemName: "xmark.circle.fill")
                    .font(.system(size: 22))
                    .foregroundColor(.gray)
                    .padding(8)
            }
        }
        .padding(8)
        .background(backgroundColor)
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
        // Usar o updateCounter como ID para forçar a recriação da view
        .id(updateTracker.updateCounter)
    }
}

/// View container para exibir o conteúdo flutuante quando necessário
public struct FloatingViewContainer: View {
    /// Ambiente para acessar o estado da view flutuante
    @ObservedObject var floatingViewState: FloatingViewState
    
    public init(floatingViewState: FloatingViewState) {
        self.floatingViewState = floatingViewState
    }
    
    public var body: some View {
        ZStack {
            // Overlay escuro quando a view flutuante está ativa
            if floatingViewState.isPresented {
                // View flutuante com o conteúdo atual
                if let content = floatingViewState.content {
                    FloatingView(
                        content: content,
                        backgroundColor: floatingViewState.backgroundColor,
                        updateTracker: floatingViewState
                    )
                }
            }
        }
        .animation(.spring(response: 0.3, dampingFraction: 0.8), value: floatingViewState.isPresented)
    }
}
