import SwiftUI
import ZenithCoreInterface

public struct AnyCheckBoxStyle: CheckBoxStyle & Sendable & Identifiable {
    public let id: UUID = .init()
    
    private let _makeBody: @Sendable (CheckBoxStyleConfiguration) -> AnyView
    
    public init<S: CheckBoxStyle>(_ style: S) {
        _makeBody = { @Sendable configuration in
            AnyView(style.makeBody(configuration: configuration))
        }
    }
    
    public func makeBody(configuration: CheckBoxStyleConfiguration) -> some View {
        _makeBody(configuration)
    }
}

public protocol CheckBoxStyle: StyleProtocol & Identifiable {
    typealias Configuration = CheckBoxStyleConfiguration
}

public struct CheckBoxStyleConfiguration {
    let text: String
    
    init(text: String) {
        self.text = text
    }
}

public struct CheckBoxStyleKey: EnvironmentKey {
    public static let defaultValue: any CheckBoxStyle = PrimaryCheckBoxStyle()
}

public extension EnvironmentValues {
    var checkboxStyle : any CheckBoxStyle {
        get { self[CheckBoxStyleKey.self] }
        set { self[CheckBoxStyleKey.self] = newValue }
    }
}

public extension CheckBoxStyle {
    @MainActor
    func resolve(configuration: Configuration) -> some View {
        ResolvedCheckBoxStyle(style: self, configuration: configuration)
    }
}

private struct ResolvedCheckBoxStyle<Style: CheckBoxStyle>: View {
    let style: Style
    let configuration: Style.Configuration
    
    var body: some View {
        style.makeBody(configuration: configuration)
    }
}
