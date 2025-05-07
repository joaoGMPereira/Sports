import SwiftUI
import Zenith
import ZenithCoreInterface
import SFSafeSymbols

struct BlurControlSection: View, @preconcurrency BaseThemeDependencies {
    @Dependency(\.themeConfigurator) var themeConfigurator
    let title: String
    @Binding var isExpanded: Bool
    @Binding var radius: Double
    @Binding var width: Double
    @Binding var height: Double
    @Binding var offsetX: Double
    @Binding var offsetY: Double
    @Binding var opacity: Double
    
    var body: some View {
        VStack {
            HStack {
                Text(title)
                    .textStyle(.largeBold(.contentA))
                
                Spacer()
                
                Button(action: {
                    withAnimation {
                        isExpanded.toggle()
                    }
                }) {
                    Image(systemSymbol: isExpanded ? .chevronUp : .chevronDown)
                        .foregroundColor(colors.contentA)
                }
                .buttonStyle(.plain)
                .contentShape(Rectangle())
                .id("\(title)-toggle-button")
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color(UIColor.systemBackground).opacity(0.8))
            )
            
            if isExpanded {
                VStack(alignment: .leading, spacing: 10) {
                    BlurSliderRow(title: "Radius", value: $radius, range: 0...100, step: 1)
                    BlurSliderRow(title: "Width", value: $width, range: 10...200, step: 1)
                    BlurSliderRow(title: "Height", value: $height, range: 10...200, step: 1)
                    BlurSliderRow(title: "Offset X", value: $offsetX, range: -100...100, step: 1)
                    BlurSliderRow(title: "Offset Y", value: $offsetY, range: -100...100, step: 1)
                    BlurSliderRow(title: "Opacity", value: $opacity, range: 0...1, step: 0.05)
                }
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color(UIColor.systemBackground).opacity(0.8))
                )
            }
        }
        .padding(.horizontal, 1)
    }
}
