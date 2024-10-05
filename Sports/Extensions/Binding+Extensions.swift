import SwiftUI

extension Binding where Value: Equatable {
    func removeDuplicates() -> Self {
        .init(
            get: { self.wrappedValue },
            set: { newValue, transaction in
                guard newValue != self.wrappedValue else { return }
                self.transaction(transaction).wrappedValue = newValue
            }
        )
    }
}

public extension Collection {
    subscript(safe index: Index) -> Element? {
        indices.contains(index) ? self[index] : nil
    }

    var isNotEmpty: Bool {
        !isEmpty
    }
}
