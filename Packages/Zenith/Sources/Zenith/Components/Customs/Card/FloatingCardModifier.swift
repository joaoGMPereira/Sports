import SwiftUI

/// Um modificador que permite que uma view seja exibida como um cartão flutuante
/// que pode ser arrastado e dispensado
public struct FloatingCardModifier<FloatingContent: View>: ViewModifier {
    // Binding para controlar o estado de flutuação
    @Binding var isPresented: Bool
    
    // Configurações visuais
    let backgroundOpacity: Double
    let backgroundBlur: Double
    let scale: CGFloat
    let showCloseButton: Bool
    let isDraggable: Bool
    
    // Estado interno para o drag
    @State private var dragOffset = CGSize.zero
    @State private var dragStartPosition = CGSize.zero
    @State private var cardPosition = CGSize.zero
    
    // Conteúdo a ser mostrado
    let floatingContent: FloatingContent
    
    public init(
        isPresented: Binding<Bool>,
        backgroundOpacity: Double = 0.6,
        backgroundBlur: Double = 10,
        scale: CGFloat = 1.1,
        showCloseButton: Bool = true,
        isDraggable: Bool = true,
        @ViewBuilder content: () -> FloatingContent
    ) {
        self._isPresented = isPresented
        self.backgroundOpacity = backgroundOpacity
        self.backgroundBlur = backgroundBlur
        self.scale = scale
        self.showCloseButton = showCloseButton
        self.isDraggable = isDraggable
        self.floatingContent = content()
    }
    
    public func body(content: Content) -> some View {
        ZStack {
            content
                .onTapGesture {
                    withAnimation(.spring()) {
                        isPresented = true
                    }
                }
            
            if isPresented {
                Color.black.opacity(backgroundOpacity)
                    .blur(radius: backgroundBlur)
                    .ignoresSafeArea()
                    .onTapGesture {
                        closeCard()
                    }
                
                VStack {
                    if showCloseButton {
                        HStack {
                            Spacer()
                            Button(action: closeCard) {
                                Image(systemName: "xmark.circle.fill")
                                    .resizable()
                                    .frame(width: 24, height: 24)
                                    .foregroundColor(.white)
                                    .padding(8)
                            }
                            .shadow(radius: 2)
                        }
                    }
                    
                    self.floatingContent
                        .scaleEffect(scale)
                }
                .offset(x: dragOffset.width, y: dragOffset.height)
                .gesture(dragGesture)
                .transition(.opacity.combined(with: .scale))
                .zIndex(100) // Garantir que esteja acima de tudo
            }
        }
    }
    
    // Gesture para drag
    private var dragGesture: some Gesture {
        DragGesture(minimumDistance: isDraggable ? 10 : 1000) // Valor alto para desativar drag se !isDraggable
            .onChanged { value in
                withAnimation(.interactiveSpring()) {
                    dragOffset = CGSize(
                        width: dragStartPosition.width + value.translation.width,
                        height: dragStartPosition.height + value.translation.height
                    )
                }
            }
            .onEnded { value in
                // Verificar se é um drag pequeno o suficiente para manter o cartão
                let velocity = value.predictedEndLocation.distance(to: value.location)
                if velocity > 500 {
                    closeCard()
                } else {
                    withAnimation(.spring()) {
                        dragOffset = dragStartPosition
                    }
                }
            }
    }
    
    private func closeCard() {
        withAnimation(.spring()) {
            isPresented = false
            dragOffset = .zero
            dragStartPosition = .zero
        }
    }
}

public extension View {
    /// Aplicar o modificador de cartão flutuante a qualquer View
    func floatingCard<Content: View>(
        isPresented: Binding<Bool>,
        backgroundOpacity: Double = 0.6,
        backgroundBlur: Double = 10,
        scale: CGFloat = 1.1,
        showCloseButton: Bool = true,
        isDraggable: Bool = true,
        @ViewBuilder content: @escaping () -> Content
    ) -> some View {
        self.modifier(
            FloatingCardModifier(
                isPresented: isPresented,
                backgroundOpacity: backgroundOpacity,
                backgroundBlur: backgroundBlur,
                scale: scale,
                showCloseButton: showCloseButton,
                isDraggable: isDraggable,
                content: content
            )
        )
    }
}

// Extensão para calcular distância entre pontos
extension CGPoint {
    func distance(to point: CGPoint) -> CGFloat {
        let xDist = self.x - point.x
        let yDist = self.y - point.y
        return sqrt(xDist * xDist + yDist * yDist)
    }
}
