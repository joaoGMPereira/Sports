import SwiftUI
import SFSafeSymbols
import Zenith
import ZenithCore

struct AppTabView: View {
    @Environment(TabRouter<TabRoute>.self) var router
    var body: some View {
        TabView(
            selection: router.tabSelection() { route in
                print(route)
            }
        ) {
            HomeView()
            .tabItem {
                Label("Home", systemSymbol: .listDash)
            }
            .tag(TabRoute.home)
            
            CommingSoonView()
            .tabItem {
                Label("Comming soon", systemSymbol: .listDash)
            }
            .tag(TabRoute.commingSoon)
            
        }
        .tint(Asset.primary.swiftUIColor)
    }

    
}

#Preview {
    AppTabView()
}
