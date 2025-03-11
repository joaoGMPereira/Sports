import SwiftUI

public protocol StyleProtocol: DynamicProperty, Sendable {
    associatedtype Configuration
    associatedtype Body: View
    
    @ViewBuilder
    func makeBody(configuration: Configuration) -> Body
}
