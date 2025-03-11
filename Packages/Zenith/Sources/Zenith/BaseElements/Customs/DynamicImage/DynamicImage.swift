import SwiftUI
import SFSafeSymbols

public enum DynamicImageType: String, Decodable, CaseIterable, Identifiable {
    public var id: String {
        rawValue
    }
    
    case async, local
}

public struct DynamicImage: View {
    @Environment(\.dynamicImageStyle) private var style
    let image: String
    let type: DynamicImageType
    
    public init (
        _ image: String
    ) {
        self.image = image
        self.type = image.starts(with: "https://") ? .async : .local
    }
    
    public init (
        _ image: SFSymbol
    ) {
        let imageRawValue = image.rawValue
        self.image = imageRawValue
        self.type = .local
    }
    
    public var body: some View {
        let asyncImage = AsyncImage(
            url: URL(
                string: image
            ),
            transaction: .init(
                animation: .snappy
            )
        ) { phase in
            if let image = phase.image {
                image.resizable()
            } else if phase.error != nil {
                Image(systemSymbol: .questionmarkApp)
                    .resizable()
            } else {
                Color.blue
            }
        }
        let image = Image(systemSymbol: .init(rawValue: image)).resizable()
        let configuration = DynamicImageStyleConfiguration(asyncImage: asyncImage, image: image, type: type)
        AnyView(style.resolve(configuration: configuration))
    }
}
