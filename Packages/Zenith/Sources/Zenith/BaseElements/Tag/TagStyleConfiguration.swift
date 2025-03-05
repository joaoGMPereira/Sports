import Dependencies
import SwiftUI
import ZenithCoreInterface

public struct AnyTagStyle: TagStyle & Sendable & Identifiable {
    public let id: UUID = .init()
    
    private let _makeBody: @Sendable (TagStyleConfiguration) -> AnyView
    
    public init<S: TagStyle>(_ style: S) {
        _makeBody = { @Sendable configuration in
            AnyView(style.makeBody(configuration: configuration))
        }
    }
    
    public func makeBody(configuration: TagStyleConfiguration) -> some View {
        _makeBody(configuration)
    }
}

public protocol TagStyle: StyleProtocol & Identifiable {
    typealias Configuration = TagStyleConfiguration
}

public struct TagStyleConfiguration {
    let text: String
    
    init(text: String) {
        self.text = text
    }
}

public struct TagStyleKey: EnvironmentKey {
    public static let defaultValue: any TagStyle = SmallTagStyle(color: .primary)
}

public extension EnvironmentValues {
    var tagStyle : any TagStyle {
        get { self[TagStyleKey.self] }
        set { self[TagStyleKey.self] = newValue }
    }
}

public extension TagStyle {
    @MainActor
    func resolve(configuration: Configuration) -> some View {
        ResolvedTagStyle(style: self, configuration: configuration)
    }
}

private struct ResolvedTagStyle<Style: TagStyle>: View {
    let style: Style
    let configuration: Style.Configuration
    
    var body: some View {
        style.makeBody(configuration: configuration)
    }
}
