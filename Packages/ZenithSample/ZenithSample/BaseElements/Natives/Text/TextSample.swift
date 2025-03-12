import SwiftUI
import Zenith

struct TextSample: View {
    @State var isExpanded = false
    
    var body: some View {
        SectionView(
            title: "TEXT",
            isExpanded: $isExpanded
        ) {
            ForEach(TextStyleCase.allCases, id: \.self) { style in
                Text("Sample Text")
                    .textStyle(style.style())
            }
        }
    }
}
