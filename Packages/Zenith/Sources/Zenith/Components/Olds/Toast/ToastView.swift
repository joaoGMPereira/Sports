import PopupView
import SwiftUI
import ZenithCoreInterface

public struct Toast: View, @preconcurrency BaseThemeDependencies {
    @Binding var title: String
    @Binding var message: String
    @Environment(\.popupDismiss) var dismiss
    @Binding var state: ToastState
    @Environment(\.safeAreaInsets) var safeAreaInsets
    
    // Implementação do protocolo BaseThemeDependencies
    @Dependency(\.themeConfigurator) public var themeConfigurator
    
    // Propriedades para animação e interatividade
    @State private var progressValue: CGFloat
    @State private var opacity: Double = 0
    @State private var offset: CGFloat = -20
    @Binding var autoDismiss: Bool
    @State private var animatingProgress = false
    
    // Timer para verificar o término da animação ao invés de incrementar o progresso
    private let timer = Timer.publish(every: 0.1, on: .main, in: .common).autoconnect()
    
    // Tempo total para o dismiss (em segundos)
    private let autoDismissDuration: Double = 3.0
    
    init(
        title: Binding<String>,
        message: Binding<String>,
        state: Binding<ToastState>,
        autoDismiss: Binding<Bool> = .constant(true)
    ) {
        self._title = title
        self._message = message
        self._state = state
        self._autoDismiss = autoDismiss
        // Inicializa o progresso baseado no valor de autoDismiss
        self._progressValue = State(initialValue: autoDismiss.wrappedValue ? 0.0 : 1.0)
    }
    
    // Determina o ícone com base no estado
    private var stateIcon: String {
        switch state {
        case .error:
            return "exclamationmark.circle.fill"
        case .info:
            return "info.circle.fill"
        }
    }
    
    // Determina as cores para o estado atual usando os tokens do design system
    private var stateColors: (background: Color, foreground: Color) {
        switch state {
        case .error:
            return (colors.danger, colors.contentA)
        case .info:
            return (colors.highlightA, colors.contentC)
        }
    }

    public var body: some View {
        ZStack {
            // Container principal com visual aprimorado
            RoundedRectangle(cornerRadius: constants.smallCornerRadius)
                .fill(stateColors.background)
                .shadow(color: colors.backgroundC.opacity(0.3), radius: 8, x: 0, y: 4)
            
            VStack(spacing: 0) {
                // Conteúdo principal
                HStack(alignment: .top, spacing: spacings.small) {
                    // Ícone representativo do estado
                    Image(systemName: stateIcon)
                        .font(fonts.mediumBold)
                        .foregroundStyle(stateColors.foreground)
                        .padding(.top, spacings.extraSmall / 2)
                    
                    VStack(alignment: .leading, spacing: spacings.extraSmall / 2) {
                        Text(title)
                            .font(fonts.mediumBold)
                            .foregroundStyle(stateColors.foreground)
                        
                        Text(message)
                            .font(fonts.small)
                            .foregroundStyle(stateColors.foreground.opacity(0.9))
                            .fixedSize(horizontal: false, vertical: true)
                            .lineLimit(3)
                    }
                    .padding(.trailing, spacings.extraSmall)
                    
                    Spacer()
                    
                    // Botão de fechar
                    Button {
                        withAnimation {
                            dismiss?()
                        }
                    } label: {
                        Image(systemName: "xmark")
                            .font(fonts.small)
                            .foregroundStyle(stateColors.foreground.opacity(0.7))
                            .padding(spacings.extraSmall)
                            .background(
                                Circle()
                                    .fill(stateColors.foreground.opacity(0.2))
                            )
                    }
                    .buttonStyle(PlainButtonStyle())
                }
                .padding(.horizontal, spacings.medium)
                .padding(.vertical, spacings.small + spacings.extraSmall)
                
                // Barra de progresso para auto-dismiss
                if autoDismiss || (!autoDismiss && progressValue == 1.0) {
                    GeometryReader { geometry in
                        Rectangle()
                            .fill(stateColors.foreground.opacity(0.5))
                            .frame(width: geometry.size.width * progressValue, height: 3)
                            .animation(.linear(duration: autoDismissDuration), value: progressValue)
                    }
                    .frame(height: 3)
                }
            }
        }
        .frame(height: (autoDismiss || (!autoDismiss && progressValue == 1.0)) ? 83 : 80)
        .padding(.horizontal, spacings.medium)
        .padding(.top, safeAreaInsets.top.wrappedValue)
        .opacity(opacity)
        .offset(y: offset)
        .onAppear {
            // Animação de entrada usando a constante de animação do design system
            withAnimation(.spring(response: constants.animationTimer, dampingFraction: 0.8)) {
                opacity = 1
                offset = 0
            }
            
            // Inicia a animação do progresso se autoDismiss estiver habilitado
            if autoDismiss {
                animatingProgress = true
                withAnimation(.linear(duration: autoDismissDuration)) {
                    progressValue = 1.0
                }
            }
        }
        .onReceive(timer) { _ in
            // Monitora o fim da animação antes de dispensar o toast
            if autoDismiss && progressValue >= 0.99 && animatingProgress {
                animatingProgress = false
                // Pequeno delay para garantir que a animação tenha terminado visualmente
                DispatchQueue.main.asyncAfter(deadline: .now() + autoDismissDuration) {
                    dismiss?()
                }
            }
        }
        .onTapGesture {
            dismiss?()
        }
    }
}

public extension View {
    func toast(toast: Binding<ToastModel>) -> some View {
        self.popup(isPresented: toast.isPresented) {
            Toast(
                title: toast.title,
                message: toast.message,
                state: toast.state,
                autoDismiss: toast.autoDismiss
            )
        } customize: {
            $0
                .type(.floater(useSafeAreaInset: true))
                .position(.top)
                .animation(.spring(response: 0.3, dampingFraction: 0.8))
                // Removemos o autohideIn para controlar o dismiss pela nossa própria animação
                .autohideIn(nil)
        }
    }
}
