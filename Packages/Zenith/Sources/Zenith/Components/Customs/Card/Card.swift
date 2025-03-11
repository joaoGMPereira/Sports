import Dependencies
import SwiftUI
import ZenithCoreInterface

public struct Card: View {
    @Environment(\.cardStyle) private var style
    let text: String
    
    public init(
        _ text: String
    ) {
        self.text = text
    }
    
    public var body: some View {
        AnyView(
            style.resolve(
                configuration: CardStyleConfiguration(
                    text: text
                )
            )
        )
    }
}
