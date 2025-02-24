import SwiftUI

@Observable
public final class Router<Routes: Routable>: RoutableObject {
    public typealias Destination = Routes

    public var stack: [Routes] = []

    public init() {}
}

public typealias Routable = View & Hashable
