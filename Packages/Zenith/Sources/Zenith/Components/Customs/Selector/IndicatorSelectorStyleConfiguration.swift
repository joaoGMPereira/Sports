import SwiftUI
import ZenithCoreInterface

public struct AnyIndicatorSelectorStyle: IndicatorSelectorStyle & Sendable & Identifiable {
    public let id: UUID = .init()
    
    private let _makeBody: @Sendable (IndicatorSelectorStyleConfiguration) -> AnyView
    
    public init<S: IndicatorSelectorStyle>(_ style: S) {
        _makeBody = { @Sendable configuration in
            AnyView(style.makeBody(configuration: configuration))
        }
    }
    
    public func makeBody(configuration: IndicatorSelectorStyleConfiguration) -> some View {
        _makeBody(configuration)
    }
}

public protocol IndicatorSelectorStyle: StyleProtocol & Identifiable {
    typealias Configuration = IndicatorSelectorStyleConfiguration
}

public struct IndicatorSelectorStyleConfiguration {
    let text: String
    let selectedValue: Double
    let minValue: Double
    let maxValue: Double
    let step: Double
    
    public init(text: String, selectedValue: Double, minValue: Double, maxValue: Double, step: Double) {
        self.text = text
        self.selectedValue = selectedValue
        self.minValue = minValue
        self.maxValue = maxValue
        self.step = step
    }
}

public struct IndicatorSelectorStyleKey: EnvironmentKey {
    public static let defaultValue: any IndicatorSelectorStyle = DefaultIndicatorSelectorStyle()
}

public extension EnvironmentValues {
    var selectorStyle : any IndicatorSelectorStyle {
        get { self[IndicatorSelectorStyleKey.self] }
        set { self[IndicatorSelectorStyleKey.self] = newValue }
    }
}

public extension IndicatorSelectorStyle {
    @MainActor
    func resolve(configuration: Configuration) -> some View {
        ResolvedIndicatorSelectorStyle(style: self, configuration: configuration)
    }
}

private struct ResolvedIndicatorSelectorStyle<Style: IndicatorSelectorStyle>: View {
    let style: Style
    let configuration: Style.Configuration
    
    var body: some View {
        style.makeBody(configuration: configuration)
    }
}
