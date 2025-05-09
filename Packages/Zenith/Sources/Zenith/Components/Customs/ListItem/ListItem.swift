import Dependencies
import SwiftUI
import ZenithCoreInterface

public struct ListItem: View {
    @Environment(\.listitemStyle) private var style
    let text: String
    
    public init(
        _ text: String
    ) {
        self.text = text
    }
    
    public var body: some View {
        AnyView(
            style.resolve(
                configuration: ListItemStyleConfiguration(
                    text: text
                )
            )
        )
    }
}
