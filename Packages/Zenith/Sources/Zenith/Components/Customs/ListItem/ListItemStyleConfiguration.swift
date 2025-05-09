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
    let text: String
    
    init(text: String) {
        self.text = text
    }
}

public struct ListItemStyleKey: EnvironmentKey {
    public static let defaultValue: any ListItemStyle = ContentAListItemStyle()
}

public extension EnvironmentValues {
    var listitemStyle : any ListItemStyle {
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
