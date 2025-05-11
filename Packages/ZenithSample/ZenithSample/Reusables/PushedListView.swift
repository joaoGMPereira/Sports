import SwiftUI
import Zenith

struct PushedListView<Content: View>: View {
    let title: String
    let content: Content
    
    init(_ title: String, @ViewBuilder content: () -> Content) {
        self.title = title
        self.content = content()
    }
    var body: some View {
        NavigationStack {
            PrincipalToolbarView.push(title) {
                List {
                    content
                }
                .listStyle(.plain)
            }
        }
    }
}
