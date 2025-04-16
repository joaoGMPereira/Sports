import SwiftUICore

public enum ImageName: String, Decodable, CaseIterable, Identifiable, Equatable {
    public var id: String {
        rawValue
    }
    
    case logo
    
    var image: Image {
        ImageAsset(name: rawValue).swiftUIImage
    }
}
