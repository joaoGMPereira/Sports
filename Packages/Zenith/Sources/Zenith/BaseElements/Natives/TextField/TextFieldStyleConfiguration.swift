import SwiftUI
import ZenithCoreInterface

public struct AnyTextFieldStyle: TextFieldStyle & Sendable & Identifiable {
    public let id: UUID = .init()
    
    private let _makeBody: @Sendable (TextFieldStyleConfiguration) -> AnyView
    
    public init<S: TextFieldStyle>(_ style: S) {
        _makeBody = { @Sendable configuration in
            AnyView(style.makeBody(configuration: configuration))
        }
    }
    
    public func makeBody(configuration: TextFieldStyleConfiguration) -> some View {
        _makeBody(configuration)
    }
}

public protocol TextFieldStyle: StyleProtocol & Identifiable {
    typealias Configuration = TextFieldStyleConfiguration
}

public struct TextFieldStyleConfiguration {
    let content: TextField<Text>
    let placeholder: String?
    let hasError: Bool
    let errorMessage: Binding<String>
    
    init(
        content: TextField<Text>,
        placeholder: String? = nil,
        hasError: Bool,
        errorMessage: Binding<String> = .constant("")
    ) {
        self.content = content
        self.placeholder = placeholder
        self.hasError = hasError
        self.errorMessage = errorMessage
    }
}

public struct TextFieldStyleKey: EnvironmentKey {
    public static let defaultValue: any TextFieldStyle = ContentATextFieldStyle(state: .enabled)
}

public extension EnvironmentValues {
    var textFieldStyle : any TextFieldStyle {
        get { self[TextFieldStyleKey.self] }
        set { self[TextFieldStyleKey.self] = newValue }
    }
}

public extension TextFieldStyle {
    @MainActor
    func resolve(configuration: Configuration) -> some View {
        ResolvedTextFieldStyle(style: self, configuration: configuration)
    }
}

private struct ResolvedTextFieldStyle<Style: TextFieldStyle>: View {
    let style: Style
    let configuration: Style.Configuration
    
    var body: some View {
        style.makeBody(configuration: configuration)
    }
}
