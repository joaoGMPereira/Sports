import SwiftUI
import Zenith

struct CardSample: View {
    @State var isExpanded = false
    
    var body: some View {
        SectionView(title: "CARD", isExpanded: $isExpanded) {
            ForEach(CardStyleCase.allCases, id: \.self) { style in
                Card("Sample Card")
                    .cardStyle(style.style())
            }
        }
    }
}
