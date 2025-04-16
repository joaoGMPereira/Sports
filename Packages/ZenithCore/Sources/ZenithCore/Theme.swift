import SwiftUI
import ZenithCoreInterface

extension Theme {
    static func light() -> Self {
        .init(
            name: .light,
            colors: LightColors(),
            fonts: Fonts(),
            spacings: Spacings(),
            constants: Constants()
        )
    }
    
    static func dark() -> Self {
        .init(
            name: .dark,
            colors: DarkColors(),
            fonts: Fonts(),
            spacings: Spacings(),
            constants: Constants()
        )
    }
}
