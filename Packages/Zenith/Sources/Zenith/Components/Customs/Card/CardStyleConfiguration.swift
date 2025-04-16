import SwiftUI
import ZenithCoreInterface

public struct AnyCardStyle: CardStyle & Sendable & Identifiable {
    public let id: UUID = .init()
    
    private let _makeBody: @Sendable (CardStyleConfiguration) -> AnyView
    
    public init<S: CardStyle>(_ style: S) {
        _makeBody = { @Sendable configuration in
            AnyView(style.makeBody(configuration: configuration))
        }
    }
    
    public func makeBody(configuration: CardStyleConfiguration) -> some View {
        _makeBody(configuration)
    }
}

public protocol CardStyle: StyleProtocol & Identifiable {
    typealias Configuration = CardStyleConfiguration
}

public struct CardStyleConfiguration {
    let image: String
    let title: String
    let arrangement: StackArrangementCase
    let action: () -> Void
    
    public init(
        image: String,
        title: String,
        arrangement: StackArrangementCase,
        action: @escaping () -> Void
    ) {
        self.image = image
        self.title = title
        self.arrangement = arrangement
        self.action = action
    }
}

public struct CardStyleKey: EnvironmentKey {
    public static let defaultValue: any CardStyle = FillCardStyle()
}

public extension EnvironmentValues {
    var cardStyle : any CardStyle {
        get { self[CardStyleKey.self] }
        set { self[CardStyleKey.self] = newValue }
    }
}

public extension CardStyle {
    @MainActor
    func resolve(configuration: Configuration) -> some View {
        ResolvedCardStyle(style: self, configuration: configuration)
    }
}

private struct ResolvedCardStyle<Style: CardStyle>: View {
    let style: Style
    let configuration: Style.Configuration
    
    var body: some View {
        style.makeBody(configuration: configuration)
    }
}
