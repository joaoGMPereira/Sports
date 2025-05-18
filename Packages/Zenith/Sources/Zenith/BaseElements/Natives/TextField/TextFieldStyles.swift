import SwiftUI
import ZenithCoreInterface
import Combine

public extension TextField where Label == Text {
    func textFieldStyle(
        _ style: some TextFieldStyle,
        placeholder: String = "",
        hasError: Bool = false,
        errorMessage: Binding<String> = .constant("")
    ) -> some View {
        AnyView(
            style.resolve(
                configuration: TextFieldStyleConfiguration(
                    content: self,
                    placeholder: placeholder,
                    hasError: hasError,
                    errorMessage: errorMessage
                )
            ).environment(\.textFieldStyle, style)
        )
    }
}

public struct ContentATextFieldStyle: @preconcurrency TextFieldStyle, BaseThemeDependencies {
    public var id = String(describing: Self.self)
    let state: DSState
    
    @Dependency(\.themeConfigurator) public var themeConfigurator: any ThemeConfiguratorProtocol
    
    @MainActor
    public func makeBody(configuration: Configuration) -> some View {
        VStack(alignment: .leading, spacing: 0) {
            // O TextField principal com o placeholder
            ZStack(alignment: .leading) {
                // O TextField original
                configuration.content
                    .foregroundStyle(colors.contentA.opacity(state == .enabled ? 1 : constants.disabledOpacity))
                    .disabled(state == .disabled)
                    .background(Color.clear)
                    .padding(.top, configuration.placeholder != nil ? 15 : 0)
                
                // Placeholder animado
                if let placeholder = configuration.placeholder {
                    PlaceholderView(
                        placeholder: placeholder, 
                        color: colors.highlightA.opacity(state == .enabled ? 1 : constants.disabledOpacity),
                        textField: configuration.content
                    )
                }
            }
            
            // Linha inferior
            Rectangle()
                .frame(height: 1)
                .foregroundStyle(
                    !configuration.errorMessage.wrappedValue.isEmpty ?
                    colors.danger.opacity(state == .enabled ? 1 : constants.disabledOpacity) :
                    colors.contentA.opacity(state == .enabled ? 1 : constants.disabledOpacity)
                )
                .padding(.top, 6)
            
            // Área para mensagem de erro - sempre com a mesma altura para evitar saltos no layout
            ZStack(alignment: .leading) {
                if !configuration.errorMessage.wrappedValue.isEmpty {
                    Text(configuration.errorMessage.wrappedValue)
                        .font(fonts.small)
                        .foregroundStyle(colors.danger.opacity(state == .enabled ? 1 : constants.disabledOpacity))
                        .padding(.top, 4)
                        .transition(.opacity)
                }
                if configuration.hasError {
                    // Espaço reservado com altura fixa para manter o layout estável
                    Color.clear
                        .frame(height: 20)
                        .padding(.top, 4)
                }
            }
        }
    }
}

public struct ContentBTextFieldStyle: @preconcurrency TextFieldStyle, BaseThemeDependencies {
    public var id = String(describing: Self.self)
    let state: DSState
    
    @Dependency(\.themeConfigurator) public var themeConfigurator: any ThemeConfiguratorProtocol
    
    @MainActor
    public func makeBody(configuration: Configuration) -> some View {
        VStack(alignment: .leading, spacing: 0) {
            // O TextField principal com o placeholder
            ZStack(alignment: .leading) {
                // O TextField original
                configuration.content
                    .foregroundStyle(colors.contentC.opacity(state == .enabled ? 1 : constants.disabledOpacity))
                    .disabled(state == .disabled)
                    .background(Color.clear)
                    .padding(.top, configuration.placeholder != nil ? 15 : 0)
                
                // Placeholder animado
                if let placeholder = configuration.placeholder {
                    PlaceholderView(
                        placeholder: placeholder, 
                        color: colors.highlightA.opacity(state == .enabled ? 1 : constants.disabledOpacity),
                        textField: configuration.content
                    )
                }
            }
            
            // Linha inferior
            Rectangle()
                .frame(height: 1)
                .foregroundStyle(
                    !configuration.errorMessage.wrappedValue.isEmpty ?
                    colors.danger.opacity(state == .enabled ? 1 : constants.disabledOpacity) :
                    colors.contentC.opacity(state == .enabled ? 1 : constants.disabledOpacity)
                )
                .padding(.top, 6)
            
            // Área para mensagem de erro - sempre com a mesma altura para evitar saltos no layout
            ZStack(alignment: .leading) {
                if !configuration.errorMessage.wrappedValue.isEmpty {
                    Text(configuration.errorMessage.wrappedValue)
                        .font(fonts.small)
                        .foregroundStyle(colors.danger.opacity(state == .enabled ? 1 : constants.disabledOpacity))
                        .padding(.top, 4)
                        .transition(.opacity)
                }
                // Espaço reservado com altura fixa para manter o layout estável
                Color.clear
                    .frame(height: 20)
                    .padding(.top, 4)
            }
        }
    }
}

public struct HighlightATextFieldStyle: @preconcurrency TextFieldStyle, BaseThemeDependencies {
    public var id = String(describing: Self.self)
    let state: DSState
    
    @Dependency(\.themeConfigurator) public var themeConfigurator: any ThemeConfiguratorProtocol
    
    @MainActor
    public func makeBody(configuration: Configuration) -> some View {
        VStack(alignment: .leading, spacing: 0) {
            // O TextField principal com o placeholder
            ZStack(alignment: .leading) {
                // O TextField original
                configuration.content
                    .foregroundStyle(colors.highlightA.opacity(state == .enabled ? 1 : constants.disabledOpacity))
                    .disabled(state == .disabled)
                    .background(Color.clear)
                    .padding(.top, configuration.placeholder != nil ? 15 : 0)
                
                // Placeholder animado
                if let placeholder = configuration.placeholder {
                    PlaceholderView(
                        placeholder: placeholder, 
                        color: colors.contentA.opacity(state == .enabled ? 1 : constants.disabledOpacity),
                        textField: configuration.content
                    )
                }
            }
            
            // Linha inferior
            Rectangle()
                .frame(height: 1)
                .foregroundStyle(
                    !configuration.errorMessage.wrappedValue.isEmpty ?
                    colors.danger.opacity(state == .enabled ? 1 : constants.disabledOpacity) :
                    colors.highlightA.opacity(state == .enabled ? 1 : constants.disabledOpacity)
                )
                .padding(.top, 6)
            
            // Área para mensagem de erro - sempre com a mesma altura para evitar saltos no layout
            ZStack(alignment: .leading) {
                if !configuration.errorMessage.wrappedValue.isEmpty {
                    Text(configuration.errorMessage.wrappedValue)
                        .font(fonts.small)
                        .foregroundStyle(colors.danger.opacity(state == .enabled ? 1 : constants.disabledOpacity))
                        .padding(.top, 4)
                        .transition(.opacity)
                }
                // Espaço reservado com altura fixa para manter o layout estável
                Color.clear
                    .frame(height: 20)
                    .padding(.top, 4)
            }
        }
    }
}

// View para mostrar o placeholder animado
private struct PlaceholderView: View, @preconcurrency BaseThemeDependencies {
    @Dependency(\.themeConfigurator) public var themeConfigurator: any ThemeConfiguratorProtocol
    
    let placeholder: String
    let color: Color
    let textField: TextField<Text>
    
    @State private var isActive: Bool = false
    @State private var text: String = ""
    @State private var subscriptions = Set<AnyCancellable>()
    
    var body: some View {
        Text(placeholder)
            .font(fonts.small)
            .foregroundStyle(color)
            .padding(.horizontal, 2)
            .offset(y: isActive || !text.isEmpty ? -12 : 0)
            .scaleEffect(isActive || !text.isEmpty ? 0.8 : 1, anchor: .leading)
            .animation(.easeOut(duration: 0.2), value: isActive)
            .animation(.easeOut(duration: 0.2), value: text)
            .onAppear {
                // Obtém o binding inicial
                if let binding = getBindingFromTextField(textField) {
                    text = binding.wrappedValue
                    
                    // Observa mudanças no texto
                    NotificationCenter.default.publisher(for: UITextField.textDidChangeNotification)
                        .sink { _ in
                            DispatchQueue.main.async {
                                text = binding.wrappedValue
                            }
                        }
                        .store(in: &subscriptions)
                    
                    // Observa quando o campo recebe foco
                    NotificationCenter.default.publisher(for: UITextField.textDidBeginEditingNotification)
                        .sink { _ in
                            withAnimation {
                                isActive = true
                            }
                        }
                        .store(in: &subscriptions)
                    
                    // Observa quando o campo perde foco
                    NotificationCenter.default.publisher(for: UITextField.textDidEndEditingNotification)
                        .sink { _ in
                            withAnimation {
                                isActive = false
                            }
                        }
                        .store(in: &subscriptions)
                }
            }
    }
    
    // Função auxiliar para obter o binding do TextField
    private func getBindingFromTextField(_ textField: TextField<Text>) -> Binding<String>? {
        let mirror = Mirror(reflecting: textField)
        for child in mirror.children {
            if let binding = child.value as? Binding<String> {
                return binding
            }
        }
        return nil
    }
}

public extension TextFieldStyle where Self == ContentATextFieldStyle {
    static func contentA(_ state: DSState = .enabled) -> Self { ContentATextFieldStyle(state: state) }
}

public extension TextFieldStyle where Self == ContentBTextFieldStyle {
    static func contentC(_ state: DSState = .enabled) -> Self { ContentBTextFieldStyle(state: state) }
}

public extension TextFieldStyle where Self == HighlightATextFieldStyle {
    static func highlightA(_ state: DSState = .enabled) -> Self { HighlightATextFieldStyle(state: state) }
}

public enum TextFieldStyleCase: String, Decodable, CaseIterable, Equatable {
    case contentA
    case contentC
    case highlightA
    case contentADisabled
    case contentCDisabled
    case highlightADisabled
    
    public var id: Self { self }
    
    public func style() -> AnyTextFieldStyle {
        switch self {
        case .contentA:
                .init(.contentA(.enabled))
        case .contentC:
                .init(.contentC(.enabled))
        case .highlightA:
                .init(.highlightA(.enabled))
        case .contentADisabled:
                .init(.contentA(.disabled))
        case .contentCDisabled:
                .init(.contentC(.disabled))
        case .highlightADisabled:
                .init(.highlightA(.disabled))
        }
    }
}
