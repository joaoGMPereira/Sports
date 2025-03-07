import SwiftUI

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

@Observable
public final class ToastSheetModel: Identifiable {
    public var id: UUID
    public var toast: ToastModel = .init()
    
    public init(toast: ToastModel) {
        self.id = .init()
        self.toast = toast
    }
}
    
@Observable
public final class ToastModel: Identifiable {
    public var id: UUID
    public var title: String = "Atenção"
    public var message: String = ""
    public var state: ToastState = .error
    public var autoDismiss: Bool = true
    public var isPresented: Bool = false
    
    public init() {
        self.id = .init()
    }
    
    public func show(
        title: String = "Atenção",
        message: String,
        state: ToastState = .error,
        autoDismiss: Bool = true
    ) {
        self.title = title
        self.message = message
        self.state = state
        self.autoDismiss = autoDismiss
        self.isPresented = true
    }
    
    public func showInfo(
        title: String = "Atenção",
        message: String,
        autoDismiss: Bool = true
    ) {
        self.title = title
        self.message = message
        self.state = .info
        self.autoDismiss = autoDismiss
        self.isPresented = true
    }
    
    public func showError(
        title: String = "Atenção",
        message: String,
        autoDismiss: Bool = true
    ) {
        self.title = title
        self.message = message
        self.state = .error
        self.autoDismiss = autoDismiss
        self.isPresented = true
    }
}
