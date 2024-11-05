import SwiftUI


@propertyWrapper
public struct EquatableBinding<Wrapped: Equatable & Hashable>: Equatable, Hashable {
    public var wrappedValue: Binding<Wrapped>

    public init(wrappedValue: Binding<Wrapped>) {
        self.wrappedValue = wrappedValue
    }

    public static func == (left: EquatableBinding<Wrapped>, right: EquatableBinding<Wrapped>) -> Bool {
        left.wrappedValue.wrappedValue == right.wrappedValue.wrappedValue
    }

    public func hash(into hasher: inout Hasher) {
        hasher.combine(wrappedValue.wrappedValue)
    }
}
