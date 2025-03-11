import SwiftUI
import ZenithCoreInterface

public struct AnyRadioButtonStyle: RadioButtonStyle & Sendable & Identifiable {
    public let id: UUID = .init()
    
    private let _makeBody: @Sendable (RadioButtonStyleConfiguration) -> AnyView
    
    public init<S: RadioButtonStyle>(_ style: S) {
        _makeBody = { @Sendable configuration in
            AnyView(style.makeBody(configuration: configuration))
        }
    }
    
    public func makeBody(configuration: RadioButtonStyleConfiguration) -> some View {
        _makeBody(configuration)
    }
}

public protocol RadioButtonStyle: StyleProtocol & Identifiable {
    typealias Configuration = RadioButtonStyleConfiguration
}

public struct RadioButtonStyleConfiguration {
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

public struct RadioButtonStyleKey: EnvironmentKey {
    public static let defaultValue: any RadioButtonStyle = DefaultRadioButtonStyle()
}

public extension EnvironmentValues {
    var radiobuttonStyle : any RadioButtonStyle {
        get { self[RadioButtonStyleKey.self] }
        set { self[RadioButtonStyleKey.self] = newValue }
    }
}

public extension RadioButtonStyle {
    @MainActor
    func resolve(configuration: Configuration) -> some View {
        ResolvedRadioButtonStyle(style: self, configuration: configuration)
    }
}

private struct ResolvedRadioButtonStyle<Style: RadioButtonStyle>: View {
    let style: Style
    let configuration: Style.Configuration
    
    var body: some View {
        style.makeBody(configuration: configuration)
    }
}
