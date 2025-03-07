import SwiftUI
import Zenith

struct DividerSample: View {
    @State var isExpanded = false
    
    var body: some View {
        SectionView(title: "DIVIDER", isExpanded: $isExpanded) {
            ForEach(DividerStyleCase.allCases, id: \.self) { style in
                Divider()
                    .dividerStyle(style.style())
            }
        }
    }
}
