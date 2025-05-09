import Dependencies
import SFSafeSymbols
import SwiftUI
import ZenithCoreInterface

public struct DetailedListItem: View {
    @Environment(\.detailedListItemStyle) private var style
    let configuration: DetailedListItemStyleConfiguration
    
    public init(
        _ configuration: DetailedListItemStyleConfiguration
    ) {
        self.configuration = configuration
    }
    
    public init(
        title: String,
        description: String = String(),
        leftInfo: Info,
        rightInfo: Info,
        action: @escaping () -> Void,
        blurStyle: BlurStyleCase = .default(.highlightA)
    ) {
        self.configuration = .init(
            title: title,
            description: description,
            leftInfo: leftInfo,
            rightInfo: rightInfo,
            blurStyle: blurStyle,
            action: action
        )
    }
    
    public init<TrailingContent: View>(
        title: String,
        description: String = String(),
        leftInfo: Info,
        rightInfo: Info,
        action: @escaping () -> Void,
        blurStyle: BlurStyleCase = .default(.highlightA),
        @ViewBuilder trailingContent: () -> TrailingContent
    ) {
        self.configuration = .init(
            title: title,
            description: description,
            leftInfo: leftInfo,
            rightInfo: rightInfo,
            blurStyle: blurStyle,
            action: action,
            trailingContent: AnyView(trailingContent())
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

extension DetailedListItem {
    public struct Info: Decodable {
        let title: String
        let description: String
        
        public init(title: String, description: String) {
            self.title = title
            self.description = description
        }
    }

}
