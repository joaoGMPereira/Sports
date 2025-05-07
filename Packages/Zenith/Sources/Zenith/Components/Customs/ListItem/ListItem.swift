import Dependencies
import SFSafeSymbols
import SwiftUI
import ZenithCoreInterface

public struct ListItem: View {
    @Environment(\.actionCardStyle) private var style
    let configuration: ListItemStyleConfiguration
    
    public init(
        _ configuration: ListItemStyleConfiguration
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

extension ListItem {
    public struct Info: Decodable {
        let title: String
        let description: String
        
        public init(title: String, description: String) {
            self.title = title
            self.description = description
        }
    }

}
