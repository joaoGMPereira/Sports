import SwiftUI
import Zenith
import ZenithCoreInterface

struct PushedListView<Content: View>: View, @preconcurrency BaseThemeDependencies {
    let title: String
    let content: Content
    @Dependency(\.themeConfigurator) var themeConfigurator
    
    init(_ title: String, @ViewBuilder content: () -> Content) {
        self.title = title
        self.content = content()
    }
    var body: some View {
        NavigationStack {
            PrincipalToolbarView.push(title) {
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
