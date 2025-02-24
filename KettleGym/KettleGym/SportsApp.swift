import SwiftUI
import Zenith
import ZenithCore
import ZenithCoreInterface
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
                TrainingProgram.self,
                WorkoutSession.self,
                WorkoutExercise.self,
                ExerciseSet.self,
                TrainingLog.self,
                ScheduledTraining.self,
                PerformedExercise.self,
                User.self,
                Exercise.self,
                SetPlan.self,
                CommingSoon.self
            ]
        )
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)
        let undoManager = UndoManager()
        
        do {
            let context = try ModelContainer(for: schema, configurations: modelConfiguration)
            context.mainContext.autosaveEnabled = false
            context.mainContext.undoManager = UndoManager()
            return context
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()
    var tabRouter: TabRouter<TabRoute> = .init(selectedTab: .home)
    @State var toast: ToastModel = .init()
    @State var insets = EdgeInsets()
            
    var body: some Scene {
        WindowGroup {
            AppTabView()
                .onAppear {
                    print(sharedModelContainer.mainContext.sqliteCommand)
                    insets = InsetsManager.getInsets()
                }
                .toast(toast: $toast)
        }
        .environment(\.safeAreaInsets, $insets)
        .environment(tabRouter)
        .environment(toast)
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
