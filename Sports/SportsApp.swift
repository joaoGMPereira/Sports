import ComposableArchitecture
import SwiftUI

@main
struct SportsApp: App {
    var body: some Scene {
        WindowGroup {
            AppView(
                store: Store(initialState: AppFeature.State()) {
                    AppFeature()
                      ._printChanges()
                  }
            )
            .eraseToAnyView()
        }
    }
}
