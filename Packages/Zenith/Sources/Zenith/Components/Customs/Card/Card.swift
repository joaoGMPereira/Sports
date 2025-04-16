import Dependencies
import SwiftUI
import ZenithCoreInterface
import SFSafeSymbols

public struct Card: View {
    @Environment(\.cardStyle) private var style
    let image: String
    let title: String
    let arrangement: StackArrangementCase
    let action: () -> Void
    
    public init(
        image: String,
        title: String,
        arrangement: StackArrangementCase,
        action: @escaping () -> Void
    ) {
        self.image = image
        self.title = title
        self.arrangement = arrangement
        self.action = action
    }
    
    public init(
        image: SFSymbol,
        title: String,
        arrangement: StackArrangementCase,
        action: @escaping () -> Void
    ) {
        self.image = image.rawValue
        self.title = title
        self.arrangement = arrangement
        self.action = action
    }
    
    public static func emptyState(
        image: SFSymbol,
        title: String,
        action: @escaping () -> Void
    ) -> Self {
        .init(
            image: image,
            title: title,
            arrangement: .verticalCenter,
            action: action
        )
    }
    
    public var body: some View {
        AnyView(
            style.resolve(
                configuration: CardStyleConfiguration(
                    image: image,
                    title: title,
                    arrangement: arrangement,
                    action: action
                )
            )
        )
    }
}
