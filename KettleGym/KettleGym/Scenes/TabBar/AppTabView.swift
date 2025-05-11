import SwiftUI
import SFSafeSymbols
import Zenith
import ZenithCoreInterface

struct AppTabView: View, @preconcurrency BaseThemeDependencies {
    @Dependency(\.themeConfigurator) var themeConfigurator: any ThemeConfiguratorProtocol
    
    init() {
        UITabBar.appearance().unselectedItemTintColor = themeConfigurator.theme.colors.contentA.uiColor()
    }
    
    @Environment(TabRouter<TabRoute>.self) var router
    var body: some View {
        TabView(
            selection: Binding { //this is the get block
                router.selectedTab
               } set: { tappedTab in
                   if tappedTab == router.selectedTab {
                       print("same tab")
                   }
                   //Set the tab to the tabbed tab
                   router.selectedTab = tappedTab
               }
        ) {
            HomeView()
            .tabItem {
                Label("Home", systemSymbol: .listDash)
                    .foregroundStyle(colors.contentA)
            }
            .tag(TabRoute.home)
            
            CommingSoonView()
            .tabItem {
                Label("Comming soon", systemSymbol: .listDash)
            }
            .tag(TabRoute.commingSoon)
            
        }
        .tint(colors.highlightA)
    }

    
}

#Preview {
    AppTabView()
}
