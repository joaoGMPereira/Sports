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
    private var isResizable: Bool
    
    public init (
        _ image: String,
        resizable: Bool = false
    ) {
        self.image = image
        self.type = image.starts(with: "https://") ? .async : .local
        self.isResizable = resizable
    }
    
    public init (
        _ image: SFSymbol,
        resizable: Bool = false
    ) {
        let imageRawValue = image.rawValue
        self.image = imageRawValue
        self.type = .local
        self.isResizable = resizable
    }
    
    public init (
        _ image: ImageName,
        resizable: Bool = false
    ) {
        let imageRawValue = image.rawValue
        self.image = imageRawValue
        self.type = .local
        self.isResizable = resizable
    }
    
    public var body: some View {
        let configuration = DynamicImageStyleConfiguration(asyncImage: asyncImage, image: localImage, type: type)
        AnyView(style.resolve(configuration: configuration))
    }
    
    private var localImage: Image {
        if let imageAsset = ImageName(rawValue: image) {
            let image = Image(asset: ImageAsset(name: imageAsset.rawValue))
            if isResizable {
                return image.resizable()
            } else {
                return image
            }
        } else {
            let image = Image(systemSymbol: .init(rawValue: image))
            if isResizable {
                return image.resizable()
            } else {
                return image
            }
        }
    }
    
    private var asyncImage: AsyncImage<_ConditionalContent<_ConditionalContent<_ConditionalContent<Image, Image>, _ConditionalContent<Image, Image>>, Color>> {
        AsyncImage(
            url: URL(
                string: image
            ),
            transaction: .init(
                animation: .snappy
            )
        ) { phase in
            if let image = phase.image {
                if isResizable {
                    image.resizable()
                } else {
                    image
                }
            } else if phase.error != nil {
                let image = Image(systemSymbol: .questionmarkApp)
                if isResizable {
                    image.resizable()
                } else {
                    image
                }
            } else {
                Color.blue
            }
        }
    }
    
    public func resizable(_ enabled: Bool = true) -> some View {
        DynamicImage(self.image, resizable: enabled)
            .environment(\.dynamicImageStyle, style)
    }
}
