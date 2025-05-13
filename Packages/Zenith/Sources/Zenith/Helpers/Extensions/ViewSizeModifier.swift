import SwiftUI

/// Chave de preferência para armazenar o tamanho (altura e largura) de uma View
public struct SizePreferenceKey: PreferenceKey {
    public static let defaultValue: CGSize = .zero
    
    public static func reduce(value: inout CGSize, nextValue: () -> CGSize) {
        value = nextValue()
    }
}

/// Chave de preferência para armazenar especificamente a altura de uma View
public struct HeightPreferenceKey: PreferenceKey {
    public static let defaultValue: CGFloat = 0
    
    public static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
        value = nextValue()
    }
}

/// Chave de preferência para armazenar especificamente a largura de uma View
public struct WidthPreferenceKey: PreferenceKey {
    public static let defaultValue: CGFloat = 0
    
    public static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
        value = nextValue()
    }
}

/// Modificador que captura o tamanho de uma View e o armazena na preferência correspondente
public struct SizeModifier: ViewModifier {
    /// Define qual dimensão será capturada
    public enum CaptureType {
        case size      // Captura tanto altura quanto largura (CGSize)
        case height    // Captura apenas a altura (CGFloat)
        case width     // Captura apenas a largura (CGFloat)
    }
    
    private let type: CaptureType
    
    public init(type: CaptureType = .size) {
        self.type = type
    }
    
    public func body(content: Content) -> some View {
        content
            .overlay(GeometryReader { geometry in
                Color.clear
                    .preference(key: SizePreferenceKey.self, value: geometry.size)
                    .preference(key: HeightPreferenceKey.self, value: geometry.size.height)
                    .preference(key: WidthPreferenceKey.self, value: geometry.size.width)
            })
    }
}

// MARK: - Extensions

public extension View {
    /// Captura o tamanho completo (altura e largura) da View e o disponibiliza através do binding
    func captureSize(_ size: Binding<CGSize>) -> some View {
        self.modifier(SizeModifier(type: .size))
            .onPreferenceChange(SizePreferenceKey.self) { newSize in
                size.wrappedValue = newSize
            }
    }
    
    /// Captura a altura da View e a disponibiliza através do binding
    func captureHeight(_ height: Binding<CGFloat>) -> some View {
        self.modifier(SizeModifier(type: .height))
            .onPreferenceChange(HeightPreferenceKey.self) { newHeight in
                height.wrappedValue = newHeight
            }
    }
    
    /// Captura a largura da View e a disponibiliza através do binding
    func captureWidth(_ width: Binding<CGFloat>) -> some View {
        self.modifier(SizeModifier(type: .width))
            .onPreferenceChange(WidthPreferenceKey.self) { newWidth in
                width.wrappedValue = newWidth
            }
    }
    
    /// Captura a altura da View e executa uma ação quando ela mudar
    func onHeightChange(_ action: @escaping (CGFloat) -> Void) -> some View {
        self.modifier(SizeModifier(type: .height))
            .onPreferenceChange(HeightPreferenceKey.self, perform: action)
    }
    
    /// Captura a largura da View e executa uma ação quando ela mudar
    func onWidthChange(_ action: @escaping (CGFloat) -> Void) -> some View {
        self.modifier(SizeModifier(type: .width))
            .onPreferenceChange(WidthPreferenceKey.self, perform: action)
    }
    
    /// Captura o tamanho completo da View e executa uma ação quando ele mudar
    func onSizeChange(_ action: @escaping (CGSize) -> Void) -> some View {
        self.modifier(SizeModifier(type: .size))
            .onPreferenceChange(SizePreferenceKey.self, perform: action)
    }
}
