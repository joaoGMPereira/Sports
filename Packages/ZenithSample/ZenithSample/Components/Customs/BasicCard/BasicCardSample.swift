import SwiftUI
import Zenith
import ZenithCoreInterface
struct BasicCardSample: View, @preconcurrency BaseThemeDependencies {
    @Dependency(\.themeConfigurator) var themeConfigurator
    
    var body: some View {
        EmptyView()
    }
}
