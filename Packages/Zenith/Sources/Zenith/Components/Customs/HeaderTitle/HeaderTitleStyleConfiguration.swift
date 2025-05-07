import SwiftUI
import ZenithCoreInterface

public struct AnyHeaderTitleStyle: HeaderTitleStyle & Sendable & Identifiable {
    public let id: UUID = .init()
    
    private let _makeBody: @Sendable (HeaderTitleStyleConfiguration) -> AnyView
    
    public init<S: HeaderTitleStyle>(_ style: S) {
        _makeBody = { @Sendable configuration in
            AnyView(style.makeBody(configuration: configuration))
        }
    }
    
    public func makeBody(configuration: HeaderTitleStyleConfiguration) -> some View {
        _makeBody(configuration)
    }
}

public protocol HeaderTitleStyle: StyleProtocol & Identifiable {
    typealias Configuration = HeaderTitleStyleConfiguration
}

public struct HeaderTitleStyleConfiguration {
    let text: String
    let image: String
    let action: (() -> Void)?
    
    init(
        text: String,
        image: String,
        action: (() -> Void)?
    ) {
        self.text = text
        self.image = image
        self.action = action
    }
}

public struct HeaderTitleStyleKey: EnvironmentKey {
    public static let defaultValue: any HeaderTitleStyle = ContentAHeaderTitleStyle()
}

public extension EnvironmentValues {
    var headerTitleStyle : any HeaderTitleStyle {
        get { self[HeaderTitleStyleKey.self] }
        set { self[HeaderTitleStyleKey.self] = newValue }
    }
}

public extension HeaderTitleStyle {
    @MainActor
    func resolve(configuration: Configuration) -> some View {
        ResolvedHeaderTitleStyle(style: self, configuration: configuration)
    }
}

private struct ResolvedHeaderTitleStyle<Style: HeaderTitleStyle>: View {
    let style: Style
    let configuration: Style.Configuration
    
    var body: some View {
        style.makeBody(configuration: configuration)
    }
}
