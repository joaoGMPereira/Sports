import SwiftUI
import UIKit

/// Gerenciador para exibir views flutuantes anexadas à Window principal do aplicativo
public class WindowFloatingManager {
    /// Instância compartilhada do gerenciador (singleton)
    @MainActor public static let shared = WindowFloatingManager()
    
    /// Controlador de view que mantém a view flutuante
    var hostingController: UIHostingController<AnyView>?
    
    /// Impede a inicialização externa
    private init() {}
    
    /// Exibe uma view SwiftUI anexada à janela principal do aplicativo
    /// - Parameters:
    ///   - content: View SwiftUI a ser exibida
    ///   - position: Posição inicial da view (centro por padrão)
    ///   - size: Tamanho da view (se nil, calcula automaticamente)
    ///   - isDraggable: Se a view pode ser arrastada
    ///   - backgroundColor: Cor de fundo do card
    ///   - showCloseButton: Se deve mostrar o botão de fechar
    /// - Returns: Identificador único para a view flutuante
    @MainActor
    public func show<Content: View>(
        @ViewBuilder content: @escaping () -> Content,
        position: CGPoint? = nil,
        size: CGSize? = nil,
        isDraggable: Bool = true,
        backgroundColor: Color,
        showCloseButton: Bool = true
    ) -> UUID {
        let id = UUID()
        
        // Remove qualquer view flutuante existente
        dismiss()
        
        // Cria uma view envolvendo o conteúdo com recursos de arrasto
        let view = FloatingWindowWrapper(
            id: id,
            content: content(),
            onDismiss: { [weak self] in self?.dismiss() },
            isDraggable: isDraggable,
            backgroundColor: backgroundColor,
            showCloseButton: showCloseButton
        )
        
        // Cria o controlador de hospedagem para a view SwiftUI
        let controller = UIHostingController(rootView: AnyView(view))
        controller.view.backgroundColor = .clear
        
        // Configure para não bloquear interações com o conteúdo abaixo
        controller.modalPresentationStyle = .overFullScreen
        controller.view.isUserInteractionEnabled = true
        
        // Define tamanho e posição iniciais
        if let size = size {
            controller.view.frame.size = size
        } else {
            controller.view.sizeToFit()
        }
        
        // Posiciona a view no centro ou na posição personalizada
        if let position = position {
            controller.view.center = position
        } else {
            // Posiciona no centro da tela, considerando tamanho após cálculo
            guard let window = UIApplication.shared.keyWindow else { return id }
            controller.view.center = CGPoint(
                x: window.bounds.midX,
                y: window.bounds.midY
            )
        }
        
        self.hostingController = controller
        
        // Adiciona à janela principal
        guard let window = UIApplication.shared.keyWindow else { return id }
        window.addSubview(controller.view)
        
        return id
    }
    
    /// Remove a view flutuante atual
    @MainActor
    public func dismiss() {
        hostingController?.view.removeFromSuperview()
        hostingController = nil
    }
}

/// View que envolve o conteúdo para adicionar funcionalidades de arrasto
struct FloatingWindowWrapper<Content: View>: View {
    let id: UUID
    let content: Content
    let onDismiss: () -> Void
    let isDraggable: Bool
    let backgroundColor: Color
    let showCloseButton: Bool
    
    @State private var offset: CGSize = .zero
    @State private var position: CGPoint?
    @State private var isDragging = false
    
    var body: some View {
        ZStack(alignment: .topTrailing) {
            // Fundo atrás do card
            RoundedRectangle(cornerRadius: 12)
                .fill(backgroundColor)
                .shadow(color: Color.black.opacity(0.3), radius: 10, x: 0, y: 5)
                .frame(width: UIScreen.main.bounds.width)
            
            // Conteúdo principal
            content
                .allowsHitTesting(false) // Desativa interações do card durante arrasto
            
            // Botão de fechar
            if showCloseButton {
                Button(action: onDismiss) {
                    Image(systemName: "xmark.circle.fill")
                        .font(.system(size: 28))
                        .foregroundColor(.white)
                        .background(Color.black.opacity(0.6))
                        .clipShape(Circle())
                        .shadow(radius: 2)
                }
                .padding(8)
                .offset(x: 10, y: -20)
                .zIndex(10) // Mantém o botão na frente
            }
        }
        .offset(x: offset.width, y: offset.height)
        .gesture(isDraggable ? dragGesture : nil)
    }
    
    private var dragGesture: some Gesture {
        DragGesture()
            .onChanged { value in
                // Indica que o card está sendo arrastado
                isDragging = true
                offset = value.translation
            }
            .onEnded { value in
                // Atualiza a posição do UIView para manter a nova posição
                if let controller = findHostingController() {
                    let newCenter = CGPoint(
                        x: controller.view.center.x + value.translation.width,
                        y: controller.view.center.y + value.translation.height
                    )
                    controller.view.center = newCenter
                }
                // Reseta offset e estado de arrasto
                offset = .zero
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                    isDragging = false
                }
            }
    }
    
    private func findHostingController() -> UIHostingController<AnyView>? {
        return WindowFloatingManager.shared.hostingController
    }
}

/// View modifier para anexar uma view à janela do aplicativo
public struct WindowFloatingViewModifier<FloatingContent: View>: ViewModifier {
    @Binding var isPresented: Bool
    let content: () -> FloatingContent
    let isDraggable: Bool
    let position: CGPoint?
    let size: CGSize?
    let backgroundColor: Color
    let showCloseButton: Bool
    
    public func body(content: Content) -> some View {
        content
            .onChange(of: isPresented) { isShowing in
                if isShowing {
                    Task { @MainActor in
                        _ = WindowFloatingManager.shared.show(
                            content: self.content,
                            position: position,
                            size: size,
                            isDraggable: isDraggable,
                            backgroundColor: backgroundColor,
                            showCloseButton: showCloseButton
                        )
                    }
                } else {
                    Task { @MainActor in
                        WindowFloatingManager.shared.dismiss()
                    }
                }
            }
            .onDisappear {
                // Garante que a view flutuante seja removida se a view pai for removida
                if isPresented {
                    Task { @MainActor in
                        WindowFloatingManager.shared.dismiss()
                        isPresented = false
                    }
                }
            }
    }
}

// Extensão para adicionar um método prático para apresentar views flutuantes na janela
public extension View {
    /// Apresenta uma view flutuante anexada à janela do aplicativo
    /// - Parameters:
    ///   - isPresented: Binding que controla a exibição da view flutuante
    ///   - isDraggable: Se a view pode ser arrastada pelo usuário
    ///   - position: Posição inicial opcional (centro da tela por padrão)
    ///   - size: Tamanho opcional da view (automático por padrão)
    ///   - backgroundColor: Cor de fundo para o card flutuante
    ///   - showCloseButton: Se deve mostrar o botão de fechar
    ///   - content: View SwiftUI a ser exibida como flutuante
    func windowFloatingView<FloatingContent: View>(
        isPresented: Binding<Bool>,
        isDraggable: Bool = true,
        position: CGPoint? = nil,
        size: CGSize? = nil,
        backgroundColor: Color,
        showCloseButton: Bool = true,
        @ViewBuilder content: @escaping () -> FloatingContent
    ) -> some View {
        modifier(
            WindowFloatingViewModifier(
                isPresented: isPresented,
                content: content,
                isDraggable: isDraggable,
                position: position,
                size: size,
                backgroundColor: backgroundColor,
                showCloseButton: showCloseButton
            )
        )
    }
}
