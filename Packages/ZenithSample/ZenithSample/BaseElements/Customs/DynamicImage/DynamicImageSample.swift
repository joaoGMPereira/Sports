import SwiftUI
import Zenith

struct DynamicImageSample: View {
    @State var isExpanded = false
    
    var body: some View {
        SectionView(title: "IMAGES", isExpanded: $isExpanded) {
            ForEach(DynamicImageStyleCase.allCases, id: \.self) { style in
                DynamicImage("checkmark")
                    .dynamicImageStyle(style.style())
                DynamicImage("https://img.icons8.com/ios/50/domain--v1.png")
                    .dynamicImageStyle(style.style())
            }
        }
    }
}
