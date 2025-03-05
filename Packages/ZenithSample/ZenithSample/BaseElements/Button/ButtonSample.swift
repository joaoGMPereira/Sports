import SwiftUI
import Zenith

struct ButtonSample: View {
    @State var isExpanded = false
    
    var body: some View {
        SectionView(title: "BUTTONS", isExpanded: $isExpanded) {
            ForEach(ButtonStyleCase.allCases, id: \.self) { style in
                Button("Primary") {
                    print("caiu aqui")
                }
                .buttonStyle(style.style())
            }
        }
    }
}
