import SwiftUI
import SwiftData

struct HomeView: View {
    @State private var router: Router<HomeRoute> = .init()
    @Environment(\.modelContext) private var modelContext
    @Query private var trainingPrograms: [TrainingProgram]
    
    var body: some View {
        RoutingView(stack: $router.stack) {
            List {
                ForEach(trainingPrograms) { trainingProgram in
                    NavigationLink(destination: HomeRoute.detail(trainingProgram)) {
                        HStack {
                            Text(trainingProgram.title)
                            Spacer()
                            Image(systemSymbol: trainingProgram.hasFinished ? .archiveboxFill : .slowmo)
                                .resizable()
                                .scaledToFit()
                                .frame(width: 15, height: 15)
                                .foregroundColor(trainingProgram.hasFinished ? .red : .yellow)
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
        router.navigate(to: .trainingProgram)
    }
    
    private func delete(at offsets: IndexSet) {
        withAnimation {
            for index in offsets {
                modelContext.delete(trainingPrograms[index])
            }
            try? modelContext.save()
        }
    }
}

enum HomeRoute: Routable {
    case trainingProgram
    case detail(_ trainingProgram: TrainingProgram)
    
    var body: some View {
        switch self {
        case .trainingProgram:
            CreateTrainingProgramView()
        case let .detail(trainingProgram):
            DetailTrainingProgramView(trainingProgram: trainingProgram)
        }
    }
}
