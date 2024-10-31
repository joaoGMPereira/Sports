import PopupView
import SwiftUI

extension UIApplication {
    var keyWindow: UIWindow? {
        connectedScenes
            .compactMap {
                $0 as? UIWindowScene
            }
            .flatMap {
                $0.windows
            }
            .first {
                $0.isKeyWindow
            }
    }
}

public enum InsetsManager {
    @MainActor
    public static func getInsets() -> EdgeInsets {
       let teste = UIApplication.shared.keyWindow?.safeAreaInsets.swiftUiInsets ?? .init()
        print(teste)
        return teste
    }
}

public struct SafeAreaInsetsKey: EnvironmentKey {
    public static let defaultValue: Binding<EdgeInsets> = .constant(.init())
}

public extension EnvironmentValues {
    var safeAreaInsets: Binding<EdgeInsets> {
        get { self[SafeAreaInsetsKey.self] }
        set { self[SafeAreaInsetsKey.self] = newValue }
    }
}

private extension UIEdgeInsets {
    var swiftUiInsets: EdgeInsets {
        EdgeInsets(top: top, leading: left, bottom: bottom, trailing: right)
    }
}


public enum ToastState {
    case error
    case info
    
    public var color: Color {
        switch self {
        case .error:
            .red
        case .info:
            .blue
        }
    }
}

public struct Toast: View {
    @Binding var title: String
    @Environment(\.popupDismiss) var dismiss
    @Binding var state: ToastState
    @Environment(\.safeAreaInsets) var safeAreaInsets
    
    init(title: Binding<String>, state: Binding<ToastState>) {
        self._title = title
        self._state = state
    }

    public var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 12)
                .fill(state.color)
            HStack {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Atenção")
                        .bold()
                        .foregroundColor(.white)
                    Text(title)
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

@Observable
public final class ToastInfo: Identifiable {
    public var id: UUID
    public var title: String
    public var state: ToastState
    public var isPresented: Bool = false
    
    public init(
        id: UUID = .init(),
        title: String,
        state: ToastState = .error,
        isPresented: Bool = false
    ) {
        self.id = id
        self.title = title
        self.state = state
        self.isPresented = isPresented
    }
    
    public func show(
        title: String,
        state: ToastState = .error
    ) {
        self.title = title
        self.state = state
        self.isPresented = true
    }
    
    public func showInfo(
        title: String
    ) {
        self.title = title
        self.state = .info
        self.isPresented = true
    }
    
    public func showError(
        title: String
    ) {
        self.title = title
        self.state = .error
        self.isPresented = true
    }
}

public extension View {
    func topPopup(toastInfo: Binding<ToastInfo>) -> some View {
        self.popup(isPresented: toastInfo.isPresented) {
            Toast(title: toastInfo.title, state: toastInfo.state)
        } customize: {
            $0
                .type(.floater(useSafeAreaInset: true))
                .position(.top)
                .autohideIn(3)
        }
    }
}
