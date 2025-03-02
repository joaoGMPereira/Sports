import Dependencies
import SwiftUI
import ZenithCoreInterface

public struct Tag: View {
    @Environment(\.tagStyle) private var style
    let text: String
    
    public init(
        _ text: String
    ) {
        self.text = text
    }
    
    public var body: some View {
        AnyView(
            style.resolve(
                configuration: TagStyleConfiguration(
                    text: text
                )
            )
        )
    }
}
