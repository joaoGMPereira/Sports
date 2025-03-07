import SwiftUI
import ZenithCoreInterface

public struct AnyTextStyle: TextStyle & Sendable & Identifiable {
    public let id: UUID = .init()
    
    private let _makeBody: @Sendable (TextStyleConfiguration) -> AnyView
    
    public init<S: TextStyle>(_ style: S) {
        _makeBody = { @Sendable configuration in
            AnyView(style.makeBody(configuration: configuration))
        }
    }
    
    nonisolated public func makeBody(configuration: TextStyleConfiguration) -> some View {
        _makeBody(configuration)
    }
}

public protocol TextStyle: StyleProtocol & Identifiable {
    typealias Configuration = TextStyleConfiguration
}

public struct TextStyleConfiguration {
    let content: Text
    
    init(content: Text) {
        self.content = content
    }
}


@MainActor
public struct TextStyleKey: @preconcurrency EnvironmentKey {
    public static let defaultValue: any TextStyle = TextStyleCase.smallTextPrimary.style()
}

public extension EnvironmentValues {
    var textStyle : any TextStyle {
        get { self[TextStyleKey.self] }
        set { self[TextStyleKey.self] = newValue }
    }
}

public extension TextStyle {
    @MainActor
    func resolve(configuration: Configuration) -> some View {
        ResolvedTextStyle(style: self, configuration: configuration)
    }
}

private struct ResolvedTextStyle<Style: TextStyle>: View {
    let style: Style
    let configuration: Style.Configuration
    
    var body: some View {
        style.makeBody(configuration: configuration)
    }
}
