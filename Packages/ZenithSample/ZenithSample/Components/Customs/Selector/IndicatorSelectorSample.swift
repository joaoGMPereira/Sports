import SwiftUI
import Zenith

struct IndicatorSelectorSample: View {
    @State var isExpanded = false
    
    var body: some View {
        SectionView(title: "SELECTOR", isExpanded: $isExpanded) {
            ForEach(IndicatorSelectorStyleCase.allCases, id: \.self) { style in
                IndicatorSelector(text: "%.1f kg", selectedValue: 65, minValue: 10, maxValue: 300, step: 0.1)
                    .selectorStyle(style.style())
            }
        }
    }
}
