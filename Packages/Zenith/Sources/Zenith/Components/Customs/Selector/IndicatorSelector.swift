import Dependencies
import SwiftUI
import ZenithCoreInterface

public struct IndicatorSelector: View {
    @Environment(\.selectorStyle) private var style
    let text: String
    let selectedValue: Double
    let minValue: Double
    let maxValue: Double
    let step: Double
    
    public init(
        text: String,
        selectedValue: Double,
        minValue: Double,
        maxValue: Double,
        step: Double
    ) {
        self.text = text
        self.selectedValue = selectedValue
        self.minValue = minValue
        self.maxValue = maxValue
        self.step = step
    }
    
    public var body: some View {
        AnyView(
            style.resolve(
                configuration: IndicatorSelectorStyleConfiguration(
                    text: text,
                    selectedValue: selectedValue,
                    minValue: minValue,
                    maxValue: maxValue,
                    step: step
                )
            )
        )
    }
}
