import PopupView
import SwiftUI

public struct Toast: View {
    @Binding var title: String
    @Binding var message: String
    @Environment(\.popupDismiss) var dismiss
    @Binding var state: ToastState
    @Environment(\.safeAreaInsets) var safeAreaInsets
    
    init(
        title: Binding<String>,
        message: Binding<String>,
        state: Binding<ToastState>
    ) {
        self._title = title
        self._message = message
        self._state = state
    }

    public var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 12)
                .fill(state.color)
            HStack {
                VStack(alignment: .leading, spacing: 8) {
                    Text(title)
                        .bold()
                        .foregroundColor(.white)
                    Text(message)
                        .foregroundColor(.white)
                }
                Spacer()
            }.padding(.horizontal, 16)
            .onTapGesture {
                dismiss?()
            }
        }
        .frame(height: 80)
        .padding(.horizontal, 16)
        .padding(.top, safeAreaInsets.top.wrappedValue)
    }
}

public extension View {
    func toast(toast: Binding<ToastModel>) -> some View {
        self.popup(isPresented: toast.isPresented) {
            Toast(
                title: toast.title,
                message: toast.message,
                state: toast.state
            )
        } customize: {
            $0
                .type(.floater(useSafeAreaInset: true))
                .position(.top)
                .autohideIn(toast.autoDismiss.wrappedValue ? 3 : nil)
        }
    }
}
