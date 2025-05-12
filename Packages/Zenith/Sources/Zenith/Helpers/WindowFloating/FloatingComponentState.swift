import SwiftUI

/// Estado global para o componente flutuante
public final class FloatingComponentState: ObservableObject {
    /// Instância compartilhada
    @MainActor public static let shared = FloatingComponentState()
    
    /// Indica se o componente está visível
    @Published public var isVisible: Bool = false
    
    /// O conteúdo atual da view flutuante (armazenado como uma função para ser recriado a cada uso)
    private var contentBuilder: (() -> AnyView)?
    
    /// Cor de fundo do componente flutuante
    @Published public var backgroundColor: Color = .white
    
    /// Contador para forçar atualizações
    @Published public var updateCounter: Int = 0
    
    private init() {}
    
    /// Mostra o componente flutuante com o conteúdo fornecido
    public func show<Content: View>(
        @ViewBuilder content: @escaping () -> Content,
        backgroundColor: Color = .white
    ) {
        self.contentBuilder = { AnyView(content()) }
        self.backgroundColor = backgroundColor
        self.isVisible = true
        self.forceUpdate()
    }
    
    /// Obtém o conteúdo atual (sempre recriado)
    public var content: AnyView? {
        return contentBuilder?()
    }
    
    /// Força uma atualização do componente
    public func forceUpdate() {
        self.updateCounter += 1
    }
    
    /// Esconde o componente flutuante
    public func hide() {
        self.isVisible = false
        self.contentBuilder = nil
    }
}
