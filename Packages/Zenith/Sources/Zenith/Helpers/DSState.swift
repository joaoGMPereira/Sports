import SwiftUI

public enum DSState: String, Sendable, Identifiable, CaseIterable {
    case disabled, enabled
    
    public var id: String {
        rawValue
    }
}
