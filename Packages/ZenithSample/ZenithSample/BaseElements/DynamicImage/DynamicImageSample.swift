import SwiftUI
import Zenith

struct DynamicImageSample: View {
    @State var isExpanded = false
    
    var body: some View {
        SectionView(title: "IMAGES", isExpanded: $isExpanded) {
            ForEach(DynamicImageStyleCase.allCases, id: \.self) { style in
                DynamicImage("checkmark")
                    .dynamicImageStyle(style.style())
            }
        }
    }
}
