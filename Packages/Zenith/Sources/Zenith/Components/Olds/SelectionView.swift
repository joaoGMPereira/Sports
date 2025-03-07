import SwiftUI
import SFSafeSymbols

public struct SelectionView: View {
    var title: String
    @Binding var selectedTitle: String
    var callback: () -> Void
    
    public init(
        title: String,
        selectedTitle: Binding<String>,
        callback: @escaping () -> Void
    ) {
        self.title = title
        self._selectedTitle = selectedTitle
        self.callback = callback
    }
    
    public var body: some View {
        Button {
            callback()
        } label: {
            HStack {
                Text(title)
                Spacer()
                if selectedTitle.isNotEmpty {
                    ChipView(label: selectedTitle, isSelected: false, style: .small) { name in
                        self.selectedTitle = ""
                    }
                }
                Image(systemSymbol: .chevronRight)
                    .foregroundColor(.gray)
            }
        }
        .foregroundStyle(Color.primary)
        .buttonStyle(WithoutBackgroundPrimaryButtonStyle())
    }
}
