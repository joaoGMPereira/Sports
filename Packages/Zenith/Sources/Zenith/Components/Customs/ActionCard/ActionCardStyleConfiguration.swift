import SwiftUI
import ZenithCoreInterface

public struct AnyActionCardStyle: ActionCardStyle & Sendable & Identifiable {
    public let id: UUID = .init()
    
    private let _makeBody: @Sendable (ActionCardStyleConfiguration) -> AnyView
    
    public init<S: ActionCardStyle>(_ style: S) {
        _makeBody = { @Sendable configuration in
            AnyView(style.makeBody(configuration: configuration))
        }
    }
    
    public func makeBody(configuration: ActionCardStyleConfiguration) -> some View {
        _makeBody(configuration)
    }
}

public protocol ActionCardStyle: StyleProtocol & Identifiable {
    typealias Configuration = ActionCardStyleConfiguration
}

public struct ActionCardStyleConfiguration {
    let title: String
    let description: String
    let image: String
    let tags: [String]
    let action: (() -> Void)
    
    init(title: String, description: String, image: String, tags: [String], action: @escaping () -> Void) {
        self.title = title
        self.description = description
        self.image = image
        self.tags = tags
        self.action = action
    }
}

public struct ActionCardStyleKey: EnvironmentKey {
    public static let defaultValue: any ActionCardStyle = PrimaryActionCardStyle()
}

public extension EnvironmentValues {
    var actionCardStyle : any ActionCardStyle {
        get { self[ActionCardStyleKey.self] }
        set { self[ActionCardStyleKey.self] = newValue }
    }
}

public extension ActionCardStyle {
    @MainActor
    func resolve(configuration: Configuration) -> some View {
        ResolvedActionCardStyle(style: self, configuration: configuration)
    }
}

private struct ResolvedActionCardStyle<Style: ActionCardStyle>: View {
    let style: Style
    let configuration: Style.Configuration
    
    var body: some View {
        style.makeBody(configuration: configuration)
    }
}
