import SwiftUI
import Zenith

struct TextSample: View {
    @State var isExpanded = false
    
    var body: some View {
        SectionView(title: "TEXTS", isExpanded: $isExpanded) {
            ForEach(TextStyleCase.allCases, id: \.self) { style in
                Text("teste")
                    .modifier(style.modifier())
            }
        }
    }
}
