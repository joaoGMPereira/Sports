import SwiftUI
import Zenith

struct TagSample: View {
    @State var isExpanded = false
    
    var body: some View {
        SectionView(title: "TAGS", isExpanded: $isExpanded) {
            ForEach(TagStyleCase.allCases) { style in
                Tag("checkmark")
                    .tagStyle(style.style())
            }
        }
    }
}
