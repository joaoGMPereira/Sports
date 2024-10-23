import SwiftUI
import SwiftData

struct HomeView: View {
    @State private var router: Router<HomeRoute> = .init()
    @Environment(\.modelContext) private var modelContext
    @Query private var workouts: [Workout]
    
    var body: some View {
        RoutingView(stack: $router.stack) {
            List {
                ForEach(workouts) { workout in
                    NavigationLink(destination: HomeRoute.detail(workout)) {
                        HStack {
                            Text(workout.title)
                            Spacer()
                            Image(systemSymbol: workout.hasFinished ? .archiveboxFill : .slowmo)
                                .resizable()
                                .scaledToFit()
                                .frame(width: 15, height: 15)
                                .foregroundColor(workout.hasFinished ? .red : .yellow)
                        }
                    }
                }
                .onDelete(perform: delete)
            }
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    EditButton()
                }
                ToolbarItem {
                    Button(action: addItem) {
                        Label("Add Item", systemImage: "plus")
                    }
                }
            }
            .navigationTitle("Home")
        }
    }
    
    private func addItem() {
        router.navigate(to: .workout)
    }
    
    private func delete(at offsets: IndexSet) {
        withAnimation {
            for index in offsets {
                modelContext.delete(workouts[index])
            }
        }
    }
}

enum HomeRoute: Routable {
    case workout
    case detail(_ workout: Workout)
    
    var body: some View {
        switch self {
        case .workout:
            CreateWorkoutView()
        case let .detail(workout):
            DetailWorkoutView(workout: workout)
        }
    }
}
