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
    
    public init (
        _ image: ImageName
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
        let configuration = DynamicImageStyleConfiguration(asyncImage: asyncImage, image: localImage, type: type)
        AnyView(style.resolve(configuration: configuration))
    }
    
    private var localImage: Image {
        if let imageAsset = ImageName(rawValue: image) {
            return Image(asset: ImageAsset(name: imageAsset.rawValue)).resizable()
        } else {
            return Image(systemSymbol: .init(rawValue: image)).resizable()
        }
    }
}
