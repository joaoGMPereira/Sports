import SwiftUI
import ZenithCoreInterface

public struct AnyListItemStyle: ListItemStyle & Sendable & Identifiable {
    public let id: UUID = .init()
    
    private let _makeBody: @Sendable (ListItemStyleConfiguration) -> AnyView
    
    public init<S: ListItemStyle>(_ style: S) {
        _makeBody = { @Sendable configuration in
            AnyView(style.makeBody(configuration: configuration))
        }
    }
    
    public func makeBody(configuration: ListItemStyleConfiguration) -> some View {
        _makeBody(configuration)
    }
}

public protocol ListItemStyle: StyleProtocol & Identifiable {
    typealias Configuration = ListItemStyleConfiguration
}

public struct ListItemStyleConfiguration {
    let title: String
    let description: String
    let leftInfo: ListItem.Info
    let rightInfo: ListItem.Info
    let blurStyle: BlurStyleCase
    let action: (() -> Void)
    let trailingContent: AnyView?
    
    init(
        title: String,
        description: String,
        leftInfo: ListItem.Info,
        rightInfo: ListItem.Info,
        blurStyle: BlurStyleCase,
        action: @escaping () -> Void,
        trailingContent: AnyView? = nil
    ) {
        self.title = title
        self.description = description
        self.leftInfo = leftInfo
        self.rightInfo = rightInfo
        self.blurStyle = blurStyle
        self.action = action
        self.trailingContent = trailingContent
    }
}

public struct ListItemStyleKey: EnvironmentKey {
    public static let defaultValue: any ListItemStyle = DefaultListItemStyle()
}

public extension EnvironmentValues {
    var actionCardStyle : any ListItemStyle {
        get { self[ListItemStyleKey.self] }
        set { self[ListItemStyleKey.self] = newValue }
    }
}

public extension ListItemStyle {
    @MainActor
    func resolve(configuration: Configuration) -> some View {
        ResolvedListItemStyle(style: self, configuration: configuration)
    }
}

private struct ResolvedListItemStyle<Style: ListItemStyle>: View {
    let style: Style
    let configuration: Style.Configuration
    
    var body: some View {
        style.makeBody(configuration: configuration)
    }
}
