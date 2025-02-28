import SwiftUI

public struct AnyViewModifier: ViewModifier {
    private let modifier: (AnyView) -> AnyView
    
    public init<M: ViewModifier>(_ modifier: M) {
        self.modifier = { AnyView($0.modifier(modifier)) }
    }
    
    public func body(content: Content) -> some View {
        modifier(AnyView(content))
    }
}
