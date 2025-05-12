import SwiftUI
import Zenith
import ZenithCoreInterface

/// Um componente reutilizável que permite que qualquer view flutue sobre a tela quando ativado
/// Este componente gerencia a animação e a transição para um estado flutuante
struct FloatingView<Content: View>: View, @preconcurrency BaseThemeDependencies {
    @Dependency(\.themeConfigurator) var themeConfigurator
    
    // Configurações do componente
    @Binding var isFloating: Bool
    let content: () -> Content
    
    // Configurações personalizáveis
    var backgroundOpacity: Double = 0.8
    var backgroundBlur: Double = 20
    var scale: Double = 1.05
    var animation: Animation = .spring(response: 0.3, dampingFraction: 0.8)
    var isDraggable: Bool = true
    
    // Estado para gerenciar a posição do componente
    @State private var offset: CGSize = .zero
    @GestureState private var dragOffset: CGSize = .zero
    @State private var position: CGSize = .zero
    
    // Posição vertical do floating (topo, centro ou base)
    enum VerticalPosition {
        case top, center, bottom
    }
    @State private var verticalPosition: VerticalPosition = .top
    
    init(isFloating: Binding<Bool>, 
         backgroundOpacity: Double = 0.8,
         backgroundBlur: Double = 20,
         scale: Double = 1.05,
         animation: Animation = .spring(response: 0.3, dampingFraction: 0.8),
         isDraggable: Bool = true,
         @ViewBuilder content: @escaping () -> Content) {
        self._isFloating = isFloating
        self.backgroundOpacity = backgroundOpacity
        self.backgroundBlur = backgroundBlur
        self.scale = scale
        self.animation = animation
        self.isDraggable = isDraggable
        self.content = content
    }
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // Conteúdo principal que pode ser pressionado para flutuar
                if !isFloating {
                    content()
                        .contentShape(Rectangle()) // Garante que a área inteira seja clicável
                        .onTapGesture {
                            withAnimation(animation) {
                                isFloating = true
                                // Reseta a posição quando o componente é aberto
                                position = .zero
                                offset = .zero
                                verticalPosition = .center
                            }
                        }
                }
                
                // Overlay que aparece quando o componente está flutuando
                if isFloating {
                    // Conteúdo flutuante com botão de fechar
                    ZStack {
                        // Conteúdo do componente
                        content()
                            .scaleEffect(scale)
                            .allowsHitTesting(false)
                    }
                    .position(calculatePosition(in: geometry.size))
                    .gesture(
                        isDraggable ?
                        DragGesture()
                            .updating($dragOffset) { value, state, _ in
                                // Aplicamos apenas o deslocamento vertical durante o drag
                                state = CGSize(width: 0, height: value.translation.height)
                            }
                            .onEnded { value in
                                // Determinamos a posição final com base na direção e velocidade do arrasto
                                let height = geometry.size.height
                                let velocity = value.predictedEndLocation.y - value.location.y
                                
                                // Decidimos a posição final com base na posição atual e no gesto
                                if verticalPosition == .center {
                                    // Se está no centro e arrastou para cima ou para baixo significativamente
                                    if value.translation.height < -height * 0.15 || velocity < -300 {
                                        verticalPosition = .top
                                    } else if value.translation.height > height * 0.15 || velocity > 300 {
                                        verticalPosition = .bottom
                                    }
                                } else if verticalPosition == .top {
                                    // Se está no topo e arrastou para baixo significativamente
                                    if value.translation.height > height * 0.15 || velocity > 300 {
                                        if value.translation.height > height * 0.3 || velocity > 600 {
                                            verticalPosition = .bottom
                                        } else {
                                            verticalPosition = .center
                                        }
                                    }
                                } else if verticalPosition == .bottom {
                                    // Se está na base e arrastou para cima significativamente
                                    if value.translation.height < -height * 0.15 || velocity < -300 {
                                        if value.translation.height < -height * 0.3 || velocity < -600 {
                                            verticalPosition = .top
                                        } else {
                                            verticalPosition = .center
                                        }
                                    }
                                }
                                
                                withAnimation(animation) {
                                    // Resetamos o offset após determinar a nova posição
                                    position = .zero
                                }
                            } : nil
                    )
                    .transition(.scale(scale: 0.95).combined(with: .opacity))
                }
            }
            .animation(animation, value: isFloating)
            .animation(animation, value: verticalPosition)
        }
    }
    
    // Calcula a posição do componente flutuante com base na posição vertical escolhida
    private func calculatePosition(in size: CGSize) -> CGPoint {
        // Aplicar o offset de arrasto durante a movimentação
        var yPosition: CGFloat
        
        switch verticalPosition {
        case .top:
            yPosition = size.height * 0.15 // 15% da altura da tela a partir do topo
        case .center:
            yPosition = size.height * 0.5 // Centro da tela
        case .bottom:
            yPosition = size.height * 0.85 // 15% da altura da tela a partir da base
        }
        
        // Adiciona o offset de arrasto durante a manipulação
        yPosition += dragOffset.height
        
        return CGPoint(x: size.width / 2, y: yPosition)
    }
}

/// Uma extensão para adicionar a funcionalidade de flutuação a qualquer view
extension View {
    func makeFloating(isFloating: Binding<Bool>,
                    backgroundOpacity: Double = 0.8,
                    backgroundBlur: Double = 20,
                    scale: Double = 1.05,
                    animation: Animation = .spring(response: 0.3, dampingFraction: 0.8),
                    isDraggable: Bool = true) -> some View {
        FloatingView(
            isFloating: isFloating,
            backgroundOpacity: backgroundOpacity,
            backgroundBlur: backgroundBlur,
            scale: scale,
            animation: animation,
            isDraggable: isDraggable
        ) {
            self
        }
    }
}

// Preview
struct FloatingView_Previews: PreviewProvider {
    static var previews: some View {
        PreviewWrapper()
    }
    
    struct PreviewWrapper: View, @preconcurrency BaseThemeDependencies {
        @Dependency(\.themeConfigurator) var themeConfigurator
        @State private var isFloating = false
        
        var body: some View {
            VStack {
                Text("Pressione o card abaixo")
                    .textStyle(.medium(.contentA))
                    .padding()
                
                FloatingView(isFloating: $isFloating, isDraggable: true) {
                    VStack(alignment: .leading, spacing: spacings.small) {
                        Text("Exemplo de Cartão")
                            .textStyle(.mediumBold(.contentA))
                        
                        Text("Este cartão flutuará quando pressionado. Arraste para cima ou para baixo!")
                            .textStyle(.small(.contentB))
                        
                        Spacer()
                        
                        HStack {
                            Spacer()
                            Text("Pressione-me")
                                .textStyle(.small(.highlightA))
                        }
                    }
                    .padding()
                    .background(colors.backgroundB)
                    .cornerRadius(12)
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(colors.backgroundC, lineWidth: 1)
                    )
                    .frame(width: 250, height: 150)
                }
                
                Spacer()
                
                Button("Toggle Floating") {
                    withAnimation {
                        isFloating.toggle()
                    }
                }
                .buttonStyle(.highlightA())
                .padding()
            }
        }
    }
}
