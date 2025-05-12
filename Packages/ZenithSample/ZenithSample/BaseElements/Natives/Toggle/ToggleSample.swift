import SwiftUI
import Zenith

struct ToggleSample: View {
    @State var isOn = false
    
    var body: some View {
        VStack(spacing: 16) {
            ForEach(ToggleStyleCase.allCases, id: \.self) { style in
                Toggle("Toggle", isOn: $isOn)
                    .toggleStyle(style.style())
            }
        }
        .padding(.vertical, 8)
    }
}
