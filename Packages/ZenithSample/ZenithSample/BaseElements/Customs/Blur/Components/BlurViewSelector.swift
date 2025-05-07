import SwiftUI
import Zenith
import ZenithCoreInterface

struct BlurViewSelector: View, @preconcurrency BaseThemeDependencies {
    @Dependency(\.themeConfigurator) var themeConfigurator
    let options: [String]
    @Binding var selectedIndex: Int
    
    var body: some View {
        VStack(alignment: .leading) {
            Text("Tipo de View")
                .textStyle(.mediumBold(.contentA))
                .padding(.horizontal)
            
            Picker("Tipo de View", selection: $selectedIndex) {
                ForEach(0..<options.count, id: \.self) { index in
                    Text(options[index]).tag(index)
                }
            }
            .pickerStyle(SegmentedPickerStyle())
            .padding(.horizontal)
        }
    }
}
