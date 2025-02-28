import SwiftUI

public protocol DynamicImageStyle: DynamicProperty, Sendable {
    
    typealias Configuration = DynamicImageStyleConfiguration
    associatedtype Body : View
    
    @ViewBuilder func makeBody(configuration: Configuration) -> Body
}

public struct DynamicImageStyleConfiguration {
    let asyncImage: AsyncImage<Image>
    let image: Image
    let type: DynamicImageType
    
    
    fileprivate init(asyncImage: AsyncImage<Image>, image: Image, type: DynamicImageType) {
        self.asyncImage = asyncImage
        self.image = image
        self.type = type
    }
}

public struct DynamicImageStyleKey: EnvironmentKey {
    public static let defaultValue: any DynamicImageStyle = PlainDynamicImageStyle()
}

public extension EnvironmentValues {
    
    fileprivate var detailStyle : any DynamicImageStyle {
        get { self[DynamicImageStyleKey.self] }
        set { self[DynamicImageStyleKey.self] = newValue }
    }
    
}

public extension DynamicImageStyle {
    @MainActor fileprivate func resolve(configuration: Configuration) -> some View {
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
