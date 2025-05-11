import SwiftUI
import ZenithCoreInterface

public struct AnyCircularProgressStyle: CircularProgressStyle & Sendable & Identifiable {
    public let id: UUID = .init()
    
    private let _makeBody: @Sendable (CircularProgressStyleConfiguration) -> AnyView
    
    public init<S: CircularProgressStyle>(_ style: S) {
        _makeBody = { @Sendable configuration in
            AnyView(style.makeBody(configuration: configuration))
        }
    }
    
    public func makeBody(configuration: CircularProgressStyleConfiguration) -> some View {
        _makeBody(configuration)
    }
}

public protocol CircularProgressStyle: StyleProtocol & Identifiable {
    typealias Configuration = CircularProgressStyleConfiguration
}

public struct CircularProgressStyleConfiguration {
    let text: String
    let progress: Double
    let size: CGFloat
    let showText: Bool
    let isAnimating: Bool
    let animated: Bool
    
    public init(text: String, progress: Double, size: CGFloat, showText: Bool, isAnimating: Bool = false, animated: Bool = false) {
        self.text = text
        self.progress = min(max(progress, 0.0), 1.0) // Garante que o progresso esteja entre 0 e 1
        self.size = size
        self.showText = showText
        self.isAnimating = isAnimating
        self.animated = animated
    }
}

public struct circularProgressStyleKey: EnvironmentKey {
    public static let defaultValue: any CircularProgressStyle = ContentACircularProgressStyle()
}

public extension EnvironmentValues {
    var circularProgressStyle: any CircularProgressStyle {
        get { self[circularProgressStyleKey.self] }
        set { self[circularProgressStyleKey.self] = newValue }
    }
}

public extension CircularProgressStyle {
    @MainActor
    func resolve(configuration: Configuration) -> some View {
        ResolvedcircularProgressStyle(style: self, configuration: configuration)
    }
}

private struct ResolvedcircularProgressStyle<Style: CircularProgressStyle>: View {
    let style: Style
    let configuration: Style.Configuration
    
    var body: some View {
        style.makeBody(configuration: configuration)
    }
}
