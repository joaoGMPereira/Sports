import SwiftUI
import Zenith
import ZenithCoreInterface

struct ListItemSample: View, @preconcurrency BaseThemeDependencies {
    @Dependency(\.themeConfigurator) var themeConfigurator
    
    var body: some View {
        ForEach(ListItemStyleCase.allCases, id: \.self) { style in
            ListItem("Sample ListItem")
                .listitemStyle(style.style())
        }
    }
}
