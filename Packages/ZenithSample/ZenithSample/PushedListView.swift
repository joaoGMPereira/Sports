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
        List {
            content
                .listRowBackground(colors.backgroundB)
                .listRowSeparator(.hidden)
        }
        .navigationTitle(title)
        .listStyle(PlainListStyle())
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                ToolBarItem()
            }
        }
    }
    
    private func ToolBarItem() -> some View {
        Button(action: {
            // Ação opcional do botão de ferramentas
        }) {
            Image(systemSymbol: .infoCircle)
                .foregroundColor(colors.highlightA)
        }
    }
}