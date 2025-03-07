import SwiftUI
import ZenithCoreInterface

public struct AnyDividerStyle: DividerStyle & Sendable & Identifiable {
    public let id: UUID = .init()
    
    private let _makeBody: @Sendable (DividerStyleConfiguration) -> AnyView
    
    public init<S: DividerStyle>(_ style: S) {
        _makeBody = { @Sendable configuration in
            AnyView(style.makeBody(configuration: configuration))
        }
    }
    
    public func makeBody(configuration: DividerStyleConfiguration) -> some View {
        _makeBody(configuration)
    }
}

public protocol DividerStyle: StyleProtocol & Identifiable {
    typealias Configuration = DividerStyleConfiguration
}

public struct DividerStyleConfiguration {
    let content: Divider
    
    init(content: Divider) {
        self.content = content
    }
}

public struct DividerStyleKey: EnvironmentKey {
    public static let defaultValue: any DividerStyle = PrimaryDividerStyle()
}

public extension EnvironmentValues {
    var dividerStyle : any DividerStyle {
        get { self[DividerStyleKey.self] }
        set { self[DividerStyleKey.self] = newValue }
    }
}

public extension DividerStyle {
    @MainActor
    func resolve(configuration: Configuration) -> some View {
        ResolvedDividerStyle(style: self, configuration: configuration)
    }
}

private struct ResolvedDividerStyle<Style: DividerStyle>: View {
    let style: Style
    let configuration: Style.Configuration
    
    var body: some View {
        style.makeBody(configuration: configuration)
    }
}
