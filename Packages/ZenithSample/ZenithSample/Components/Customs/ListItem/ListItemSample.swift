import SwiftUI
import Zenith
import ZenithCoreInterface

struct ListItemSample: View, @preconcurrency BaseThemeDependencies {
    @Dependency(\.themeConfigurator) var themeConfigurator
    @State var isExpanded = false
    
    var body: some View {
        SectionView(title: "LISTITEM", isExpanded: $isExpanded) {
            ForEach(ListItemStyleCase.allCases, id: \.self) { style in
                ListItem("Sample ListItem")
                    .listitemStyle(style.style())
            }
        }
    }
}
