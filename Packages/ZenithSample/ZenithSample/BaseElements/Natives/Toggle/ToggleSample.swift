import SwiftUI
import Zenith

struct ToggleSample: View {
    @State var isExpanded = false
    @State var isOn = false
    
    var body: some View {
        SectionView(title: "TOGGLE", isExpanded: $isExpanded) {
            ForEach(ToggleStyleCase.allCases, id: \.self) { style in
                Toggle("teste", isOn: $isOn)
                    .toggleStyle(style.style())
            }
        }
    }
}
