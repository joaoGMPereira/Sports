import SwiftUI
import Zenith
import ZenithCoreInterface

struct BlurSliderRow: View, @preconcurrency BaseThemeDependencies {
    @Dependency(\.themeConfigurator) var themeConfigurator
    let title: String
    @Binding var value: Double
    let range: ClosedRange<Double>
    let step: Double
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack {
                Text(title)
                    .font(fonts.small)
                    .foregroundColor(colors.contentA)
                
                Spacer()
                
                Text("\(value, specifier: "%.2f")")
                    .font(fonts.small)
                    .foregroundColor(colors.contentC)
            }
            
            Slider(value: $value, in: range, step: step)
                .accentColor(colors.highlightA)
        }
    }
}
