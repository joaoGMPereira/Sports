import ComposableArchitecture
import SwiftUINavigation
import SwiftUI
import SFSafeSymbols
extension ColorAsset {
    var swiftUIColor: SwiftUI.Color {
        .init(uiColor: self.color)
    }
}

struct AppView: View {
    @Bindable var store: StoreOf<AppFeature>
    var body: some View {
        TabView(
            selection: $store.selectedTab.sending(\.selectedTabChanged)
        ) {
            WorkoutsView(
                store: self.store.scope(
                    state: \.workoutsTab,
                    action: \.workoutsTab
                )
            )
            .tabItem {
                Label(L10n.Tabs.workouts, systemSymbol: .listDash).eraseToAnyView()
            }
            .tag(Tab.workouts)
            //            ExercisesView()
            //                .tabItem {
            //                    Label("Exercícios", systemSymbol: .listClipboard).eraseToAnyView()
            //                }
        }
        .tint(Asset.primary.swiftUIColor)
    }
#if DEBUG
    @ObservedObject var iO = injectionObserver
#endif
}

#Preview {
    AppView(
        store: Store(
            initialState: AppFeature.State()
        ) {
            AppFeature()
        }
    )
}
