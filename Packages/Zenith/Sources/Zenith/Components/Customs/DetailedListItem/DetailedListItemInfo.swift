import Foundation

public struct DetailedListItemInfo: Decodable, Equatable, AnyStruct {
    let title: String
    let description: String
    
    public init(title: String = "", description: String = "") {
        self.title = title
        self.description = description
    }
}
