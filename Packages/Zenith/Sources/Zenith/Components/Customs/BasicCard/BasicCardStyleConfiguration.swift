import SwiftUI
import ZenithCoreInterface

public struct AnyBasicCardStyle: BasicCardStyle & Sendable & Identifiable {
    public let id: UUID = .init()
    
    private let _makeBody: @Sendable (BasicCardStyleConfiguration) -> AnyView
    
    public init<S: BasicCardStyle>(_ style: S) {
        _makeBody = { @Sendable configuration in
            AnyView(style.makeBody(configuration: configuration))
        }
    }
    
    public func makeBody(configuration: BasicCardStyleConfiguration) -> some View {
        _makeBody(configuration)
    }
}

public protocol BasicCardStyle: StyleProtocol & Identifiable {
    typealias Configuration = BasicCardStyleConfiguration
}

public struct BasicCardStyleConfiguration {
    let image: String
    let title: String
    let arrangement: StackArrangementCase
    let contentLayout: CardLayoutCase
    let action: () -> Void
    
    public init(
        image: String,
        title: String,
        arrangement: StackArrangementCase,
        contentLayout: CardLayoutCase,
        action: @escaping () -> Void
    ) {
        self.image = image
        self.title = title
        self.arrangement = arrangement
        self.contentLayout = contentLayout
        self.action = action
    }
}

public struct BasicCardStyleKey: EnvironmentKey {
    public static let defaultValue: any BasicCardStyle = FillBasicCardStyle()
}

public extension EnvironmentValues {
    var cardStyle : any BasicCardStyle {
        get { self[BasicCardStyleKey.self] }
        set { self[BasicCardStyleKey.self] = newValue }
    }
}

public extension BasicCardStyle {
    @MainActor
    func resolve(configuration: Configuration) -> some View {
        ResolvedBasicCardStyle(style: self, configuration: configuration)
    }
}

private struct ResolvedBasicCardStyle<Style: BasicCardStyle>: View {
    let style: Style
    let configuration: Style.Configuration
    
    var body: some View {
        style.makeBody(configuration: configuration)
    }
}

public enum CardLayoutCase: String, Decodable, CaseIterable, Equatable {
    case imageText
    case imageSpacerText
    case textImage
    case textSpacerImage
    
    var hasSpacer: Bool {
        switch self {
        case .imageText, .textImage:
            return false
        case .imageSpacerText, .textSpacerImage:
            return true
        }
    }
}
