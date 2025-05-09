import SwiftUI
import ZenithCoreInterface

public struct AnyDetailedListItemStyle: DetailedListItemStyle & Sendable & Identifiable {
    public let id: UUID = .init()
    
    private let _makeBody: @Sendable (DetailedListItemStyleConfiguration) -> AnyView
    
    public init<S: DetailedListItemStyle>(_ style: S) {
        _makeBody = { @Sendable configuration in
            AnyView(style.makeBody(configuration: configuration))
        }
    }
    
    public func makeBody(configuration: DetailedListItemStyleConfiguration) -> some View {
        _makeBody(configuration)
    }
}

public protocol DetailedListItemStyle: StyleProtocol & Identifiable {
    typealias Configuration = DetailedListItemStyleConfiguration
}

public struct DetailedListItemStyleConfiguration {
    let title: String
    let description: String
    let leftInfo: DetailedListItem.Info
    let rightInfo: DetailedListItem.Info
    let blurStyle: BlurStyleCase
    let action: (() -> Void)
    let trailingContent: AnyView?
    
    init(
        title: String,
        description: String,
        leftInfo: DetailedListItem.Info,
        rightInfo: DetailedListItem.Info,
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

public struct DetailedListItemStyleKey: EnvironmentKey {
    public static let defaultValue: any DetailedListItemStyle = DefaultDetailedListItemStyle()
}

public extension EnvironmentValues {
    var detailedListItemStyle : any DetailedListItemStyle {
        get { self[DetailedListItemStyleKey.self] }
        set { self[DetailedListItemStyleKey.self] = newValue }
    }
}

public extension DetailedListItemStyle {
    @MainActor
    func resolve(configuration: Configuration) -> some View {
        ResolvedDetailedListItemStyle(style: self, configuration: configuration)
    }
}

private struct ResolvedDetailedListItemStyle<Style: DetailedListItemStyle>: View {
    let style: Style
    let configuration: Style.Configuration
    
    var body: some View {
        style.makeBody(configuration: configuration)
    }
}
