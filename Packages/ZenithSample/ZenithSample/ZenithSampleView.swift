import SwiftUI
import Zenith
import SFSafeSymbols
import ZenithCoreInterface

struct ZenithSampleView: View, @preconcurrency BaseThemeDependencies {
    @Dependency(\.themeConfigurator) var themeConfigurator
    
    var body: some View {
        NavigationView {
            List {
                DynamicImageSample()
                ButtonSample()
                TextSample()
                TagSample()
                DividerSample()
                TextSample()
            }
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Text("Sample")
                        .font(fonts.mediumBold.font)
                        .foregroundColor(colors.textPrimary)
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .scrollContentBackground(.hidden)
            .background(colors.background)
        }
    }
}

// MARK: - Preview
struct ZenithSampleView_Previews: PreviewProvider {
    static var previews: some View {
        ZenithSampleView()
    }
}
