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
