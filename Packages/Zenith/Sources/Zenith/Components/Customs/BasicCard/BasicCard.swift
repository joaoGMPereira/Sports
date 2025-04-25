import Dependencies
import SwiftUI
import ZenithCoreInterface
import SFSafeSymbols

public struct BasicCard: View {
    @Environment(\.cardStyle) private var style
    let image: String
    let title: String
    let arrangement: StackArrangementCase
    let contentLayout: CardLayoutCase
    let action: () -> Void
    
    public init(
        image: String,
        title: String,
        arrangement: StackArrangementCase,
        contentLayout: CardLayoutCase,
        action: @escaping () -> Void
    ) {
        self.image = image
        self.title = title
        self.arrangement = arrangement
        self.contentLayout = contentLayout
        self.action = action
    }
    
    public init(
        image: SFSymbol,
        title: String,
        arrangement: StackArrangementCase,
        contentLayout: CardLayoutCase,
        action: @escaping () -> Void
    ) {
        self.image = image.rawValue
        self.title = title
        self.arrangement = arrangement
        self.contentLayout = contentLayout
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
            contentLayout: .imageText,
            action: action
        )
    }
    
    public var body: some View {
        AnyView(
            style.resolve(
                configuration: BasicCardStyleConfiguration(
                    image: image,
                    title: title,
                    arrangement: arrangement,
                    contentLayout: contentLayout,
                    action: action
                )
            )
        )
    }
}
