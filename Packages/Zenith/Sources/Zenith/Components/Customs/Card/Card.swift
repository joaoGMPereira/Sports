import Dependencies
import SwiftUI
import ZenithCoreInterface
import SFSafeSymbols

public struct Card: View {
    @Environment(\.cardStyle) private var style
    let image: String
    let title: String
    let arrangement: StackArrangementCase
    
    public init(
        image: String,
        title: String,
        arrangement: StackArrangementCase
    ) {
        self.image = image
        self.title = title
        self.arrangement = arrangement
    }
    
    public init(
        image: SFSymbol,
        title: String,
        arrangement: StackArrangementCase
    ) {
        self.image = image.rawValue
        self.title = title
        self.arrangement = arrangement
    }
    
    public static func emptyState(
        image: SFSymbol,
        title: String
    ) -> Self {
        .init(
            image: image,
            title: title,
            arrangement: .verticalCenter
        )
    }
    
    public var body: some View {
        AnyView(
            style.resolve(
                configuration: CardStyleConfiguration(
                    image: image,
                    title: title,
                    arrangement: arrangement
                )
            )
        )
    }
}
