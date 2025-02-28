import SwiftUI
import ZenithCoreInterface

public extension View {
    func detailStyle(_ style: some DynamicImageStyle) -> some View {
        environment(\.detailStyle, style)
    }
}

public struct PlainDynamicImageStyle: DynamicImageStyle {
    public func makeBody(configuration: Configuration) -> some View {
        Group {
            if configuration.type == .async {
                configuration.asyncImage
            } else {
                configuration.image
            }
        }
    }
}


public struct PrimaryDynamicImageStyle: DynamicImageStyle {
    
    public func makeBody(configuration: Configuration) -> some View {
        Group {
            if configuration.type == .async {
                configuration.asyncImage
            } else {
                configuration.image
            }
        }
    }
}
