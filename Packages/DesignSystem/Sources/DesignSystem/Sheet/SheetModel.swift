import SwiftUI

@Observable
public final class GridSheetModel: Identifiable {
    public var id: UUID
    var isPresented: Bool
    var items: [String]
    
    public init(isPresented: Bool = false, items: [String]) {
        self.id = .init()
        self.isPresented = isPresented
        self.items = items
    }
    
    public func set(items: [String]) {
        self.id = .init()
        self.isPresented = true
        self.items = Array(items)
    }
    public func dismiss() {
        self.isPresented = false
        self.items = []
    }
}
