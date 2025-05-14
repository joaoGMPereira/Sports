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
    @Binding var isSelected: Bool
    @Binding var isDisabled: Bool
    init(
        isSelected: Binding<Bool>,
        text: String = "",
        isDisabled: Binding<Bool>
    ) {
        self._isSelected = isSelected
        self.text = text
        self._isDisabled = isDisabled
    }
}

public struct CheckBoxStyleKey: EnvironmentKey {
    public static let defaultValue: any CheckBoxStyle = DefaultCheckBoxStyle()
}

public extension EnvironmentValues {
    var checkBoxStyle : any CheckBoxStyle {
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
