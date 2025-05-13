import SwiftUI
import Zenith
import ZenithCoreInterface

struct PushedListView<Content: View>: View, @preconcurrency BaseThemeDependencies {
    let title: String
    let content: Content
    let overrideList: Bool
    @Dependency(\.themeConfigurator) var themeConfigurator
    
    init(_ title: String, overrideList: Bool, @ViewBuilder content: () -> Content) {
        self.title = title
        self.overrideList = overrideList
        self.content = content()
    }
    var body: some View {
        NavigationStack {
            PrincipalToolbarView.push(title) {
                if overrideList {
                    content
                } else {
                    List {
                        content
                            .listRowBackground(colors.backgroundB)
                            .listRowSeparator(.hidden)
                    }
                    .listStyle(.plain)
                }
            }
        }
    }
}
