import SwiftUI
import ZenithCoreInterface

extension Theme {
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
