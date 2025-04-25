import SwiftUI
import ZenithCoreInterface

public struct Card<Content: View>: View, @preconcurrency BaseThemeDependencies {
    @Dependency(\.themeConfigurator) public var themeConfigurator: any ThemeConfiguratorProtocol
    @GestureState private var isPressed = false
    let alignment: Alignment
    let type: CardType
    let content: Content
    let action: () -> Void
    
    public init(
        alignment: Alignment,
        type: CardType,
        action: @escaping () -> Void,
        @ViewBuilder content: () -> Content
    ) {
        self.alignment = alignment
        self.type = type
        self.action = action
        self.content = content()
    }
    
    public var body: some View {
        Button(action: {
            action()
        }) {
            content
                .padding(themeConfigurator.theme.spacings.medium)
                .frame(maxWidth: .infinity, alignment: alignment)
        }
        .buttonStyle(.cardAppearance(type))
    }
}

public enum CardType: String, CaseIterable, Decodable, Identifiable {
    public var id: String {
        rawValue
    }
    
    case fill, bordered
}

