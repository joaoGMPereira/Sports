import SwiftUI

/// Objeto de ambiente para gerenciar o estado de views flutuantes em SwiftUI
public class FloatingViewState: ObservableObject {
    /// Controla se a view flutuante está sendo exibida
    @Published public var isPresented: Bool = false
    
    /// Cor de fundo da view flutuante
    @Published public var backgroundColor: Color = .clear
    
    /// Um counter para forçar atualizações da view
    @Published public var updateCounter: Int = 0
    
    /// ViewBuilder para o conteúdo
    private var contentBuilder: (() -> AnyView)?
    
    public init(content: AnyView? = nil) {
        if let content = content {
            self.contentBuilder = { content }
        }
    }
    
    /// Mostra uma view flutuante com o conteúdo fornecido
    public func show<Content: View>(@ViewBuilder content: @escaping () -> Content, backgroundColor: Color = .white) {
        // Armazenar o builder de conteúdo para que seja recriado a cada vez que for solicitado
        self.contentBuilder = { AnyView(content()) }
        self.backgroundColor = backgroundColor
        self.isPresented = true
        updateCounter += 1
    }
    
    /// Acessor do conteúdo - sempre recria o conteúdo quando solicitado
    var content: AnyView? {
        return contentBuilder?()
    }
    
    /// Remove a view flutuante atual
    public func dismiss() {
        self.isPresented = false
        self.contentBuilder = nil
    }
}

/// Chave do ambiente para acessar o estado de views flutuantes
public struct FloatingViewStateKey: @preconcurrency EnvironmentKey {
    @MainActor public static let defaultValue = FloatingViewState()
}

/// Extensão do EnvironmentValues para incluir o estado de views flutuantes
public extension EnvironmentValues {
    var floatingViewState: FloatingViewState {
        get { self[FloatingViewStateKey.self] }
        set { self[FloatingViewStateKey.self] = newValue }
    }
}

/// Extensão para facilitar o acesso ao estado de views flutuantes a partir de qualquer view
public extension View {
    /// Apresenta uma view flutuante usando o estado de floating compartilhado
    func showFloatingView<Content: View>(@ViewBuilder content: @escaping () -> Content, background: Color = .white) -> some View {
        let state = FloatingViewState()
        state.show(content: content, backgroundColor: background)
        return self.environment(\.floatingViewState, state)
    }
}
