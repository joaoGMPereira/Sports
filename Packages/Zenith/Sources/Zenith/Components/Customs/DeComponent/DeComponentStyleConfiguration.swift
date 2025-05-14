import SwiftUI
import ZenithCoreInterface

public struct AnyDeComponentStyle: DeComponentStyle & Sendable & Identifiable {
    public let id: UUID = .init()
    
    private let _makeBody: @Sendable (DeComponentStyleConfiguration) -> AnyView
    
    public init<S: DeComponentStyle>(_ style: S) {
        _makeBody = { @Sendable configuration in
            AnyView(style.makeBody(configuration: configuration))
        }
    }
    
    public func makeBody(configuration: DeComponentStyleConfiguration) -> some View {
        _makeBody(configuration)
    }
}

public protocol DeComponentStyle: StyleProtocol & Identifiable {
    typealias Configuration = DeComponentStyleConfiguration
}

public struct DeComponentStyleConfiguration {
    let text: String
    
    init(text: String) {
        self.text = text
    }
}

public struct DeComponentStyleKey: EnvironmentKey {
    public static let defaultValue: any DeComponentStyle = ContentADeComponentStyle()
}

public extension EnvironmentValues {
    var decomponentStyle : any DeComponentStyle {
        get { self[DeComponentStyleKey.self] }
        set { self[DeComponentStyleKey.self] = newValue }
    }
}

public extension DeComponentStyle {
    @MainActor
    func resolve(configuration: Configuration) -> some View {
        ResolvedDeComponentStyle(style: self, configuration: configuration)
    }
}

private struct ResolvedDeComponentStyle<Style: DeComponentStyle>: View {
    let style: Style
    let configuration: Style.Configuration
    
    var body: some View {
        style.makeBody(configuration: configuration)
    }
}
