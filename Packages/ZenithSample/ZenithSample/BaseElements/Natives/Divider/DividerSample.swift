import SwiftUI
import Zenith

struct DividerSample: View {
    var body: some View {
        ForEach(DividerStyleCase.allCases, id: \.self) { style in
            Divider()
                .dividerStyle(style.style())
        }
    }
}
