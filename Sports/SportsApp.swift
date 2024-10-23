import SwiftUI
import SwiftData
import DebugSwift

extension UIWindow {
    open override func motionEnded(_ motion: UIEvent.EventSubtype, with event: UIEvent?) {
        super.motionEnded(motion, with: event)
        
        if motion == .motionShake {
            DebugSwift
                .setup()
                .show()
            DebugSwift.toggle()
        }
    }
}

@main
struct SportsApp: App {
    var sharedModelContainer: ModelContainer = {
        let schema = Schema(
            [
                Workout.self,
                Training.self,
                SetExecution.self,
                Execution.self,
                ExecutionTraining.self,
                ExecutionExercise.self,
                Owner.self,
                Exercise.self,
                Serie.self,
                CommingSoon.self
            ]
        )
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)

        do {
            let context = try ModelContainer(for: schema, configurations: [modelConfiguration])
            context.mainContext.autosaveEnabled = false
            return context
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()
    var tabRouter: TabRouter<TabRoute> = .init(selectedTab: .home)
    var body: some Scene {
        WindowGroup {
            AppTabView()
                .onAppear {
                   print(sharedModelContainer.mainContext.sqliteCommand)
                }
        }
        .environment(tabRouter)
        .modelContainer(sharedModelContainer)
    }
}

extension ModelContext {
    var sqliteCommand: String {
        if let url = container.configurations.first?.url.path(percentEncoded: false) {
            "sqlite3 \"\(url)\""
        } else {
            "No SQLite database found."
        }
    }
}
