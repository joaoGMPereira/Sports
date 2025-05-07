import Dependencies
import SwiftUI
import ZenithCoreInterface
import SFSafeSymbols

// Chave de preferência para armazenar a altura do HeaderTitle
struct HeaderTitleHeightKey: PreferenceKey {
    static let defaultValue: CGFloat = 0
    
    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
        value = nextValue()
    }
}

public struct HeaderTitle: View {
    @Environment(\.headerTitleStyle) private var style
    let text: String
    let image: String
    let action: (() -> Void)?
    
    public init(
        _ text: String,
        image: String = String(),
        action: (() -> Void)? = nil
    ) {
        self.text = text
        self.image = image
        self.action = action
    }
    
    public init(
        _ text: String,
        image: SFSymbol,
        action: (() -> Void)? = nil
    ) {
        self.text = text
        self.image = image.rawValue
        self.action = action
    }
    
    public var body: some View {
        AnyView(
            style.resolve(
                configuration: HeaderTitleStyleConfiguration(
                    text: text,
                    image: image,
                    action: action
                )
            )
        )
    }
}
