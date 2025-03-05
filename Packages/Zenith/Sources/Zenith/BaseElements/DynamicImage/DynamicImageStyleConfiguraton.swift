import SwiftUI

public struct AnyDynamicImageStyle: DynamicImageStyle & Sendable & Identifiable {
    public let id: UUID = .init()
    
    private let _makeBody: @Sendable (DynamicImageStyleConfiguration) -> AnyView
    
    public init<S: DynamicImageStyle>(_ style: S) {
        _makeBody = { @Sendable configuration in
            AnyView(style.makeBody(configuration: configuration))
        }
    }
    
    public func makeBody(configuration: DynamicImageStyleConfiguration) -> some View {
        _makeBody(configuration)
    }
}

public protocol DynamicImageStyle: DynamicProperty, Sendable {
    
    typealias Configuration = DynamicImageStyleConfiguration
    associatedtype Body : View
    
    @ViewBuilder func makeBody(configuration: Configuration) -> Body
}

public struct DynamicImageStyleConfiguration {
    let asyncImage: AsyncImage<_ConditionalContent<_ConditionalContent<Image, Image>, Color>>
    let image: Image
    let type: DynamicImageType
    
    
    init(asyncImage: AsyncImage<_ConditionalContent<_ConditionalContent<Image, Image>, Color>>, image: Image, type: DynamicImageType) {
        self.asyncImage = asyncImage
        self.image = image
        self.type = type
    }
}

public struct DynamicImageStyleKey: EnvironmentKey {
    public static let defaultValue: any DynamicImageStyle = SmallDynamicImageStyle(color: .primary)
}

public extension EnvironmentValues {
    
    var dynamicImageStyle : any DynamicImageStyle {
        get { self[DynamicImageStyleKey.self] }
        set { self[DynamicImageStyleKey.self] = newValue }
    }
    
}

public extension DynamicImageStyle {
    @MainActor
    func resolve(configuration: Configuration) -> some View {
        ResolvedDynamicImageStyle(style: self, configuration: configuration)
    }
}

private struct ResolvedDynamicImageStyle<Style: DynamicImageStyle>: View {
    let style: Style
    let configuration: Style.Configuration
    
    var body: some View {
        style.makeBody(configuration: configuration)
    }
}
