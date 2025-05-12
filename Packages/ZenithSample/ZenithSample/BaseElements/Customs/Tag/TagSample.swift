import SwiftUI
import Zenith

struct TagSample: View {
    var body: some View {
        VStack(spacing: 16) {
            ForEach(TagStyleCase.allCases) { style in
                Tag("checkmark")
                    .tagStyle(style.style())
            }
        }
        .padding(.vertical, 8)
    }
}
