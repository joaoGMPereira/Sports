import SwiftUI
import Zenith

struct CheckBoxSample: View {
    @State var isExpanded = false
    
    var body: some View {
        SectionView(title: "CHECKBOX", isExpanded: $isExpanded) {
            ForEach(CheckBoxStyleCase.allCases, id: \.self) { style in
                CheckBox("Sample CheckBox")
                    .checkboxStyle(style.style())
            }
        }
    }
}
