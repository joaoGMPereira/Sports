import Dependencies
import SFSafeSymbols
import SwiftUI
import ZenithCoreInterface


public struct ActionCard: View {
    @Environment(\.actionCardStyle) private var style
    let configuration: ActionCardStyleConfiguration
    
    public init(
        _ configuration: ActionCardStyleConfiguration
    ) {
        self.configuration = configuration
    }
    
    public init(
        title: String,
        description: String,
        image: String,
        tags: [String],
        action: @escaping () -> Void
    ) {
        self.configuration = .init(
            title: title,
            description: description,
            image: image,
            tags: tags,
            action: action
        )
    }
    
    public init(
        title: String,
        description: String,
        image: SFSymbol,
        tags: [String],
        action: @escaping () -> Void
    ) {
        self.configuration = .init(
            title: title,
            description: description,
            image: image.rawValue,
            tags: tags,
            action: action
        )
    }
    
    public var body: some View {
        AnyView(
            style.resolve(
                configuration: configuration
            )
        )
    }
}
