import SwiftUI
import SwiftData

struct HomeView: View {
    @State private var trainingProgrammingRouter: Router<TrainingProgramRoute> = .init()
    @Environment(\.modelContext) private var modelContext
    @Query private var trainingPrograms: [TrainingProgram]
    
    var body: some View {
        RoutingView(stack: $trainingProgrammingRouter.stack) {
            List {
                ForEach(trainingPrograms) { trainingProgram in
                    Button {
                        trainingProgrammingRouter.navigate(to: .detail(trainingProgram))
                    } label: {
                        HStack {
                            Text(trainingProgram.title)
                                .foregroundStyle(Color.primary)
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
        .environment(trainingProgrammingRouter)
        .onAppear {
           // try? removeDuplicateSetPlans()
        }
    }
    
//    func removeDuplicateSetPlans() throws {
//        let allSetPlans = try? modelContext.fetch(FetchDescriptor<SetPlan>())
//
//        // Agrupa os SetPlans usando um dicionário, onde a chave são os valores de quantity, minRep e maxRep
//        var uniqueSetPlans: [String: SetPlan] = [:]
//        var duplicates: [SetPlan] = []
//
//        for setPlan in allSetPlans ?? [] {
//            guard let quantity = setPlan.quantity, let minRep = setPlan.minRep, let maxRep = setPlan.maxRep else {
//                continue
//            }
//
//            // Cria uma chave única usando os valores dos atributos que definem a duplicidade
//            let key = "\(quantity)-\(minRep)-\(maxRep)"
//
//            if uniqueSetPlans[key] == nil {
//                uniqueSetPlans[key] = setPlan
//            } else {
//                // Caso o SetPlan já exista, marca-o como duplicado
//                duplicates.append(setPlan)
//            }
//        }
//
//        // Remove os objetos duplicados
//        for duplicate in duplicates {
//            modelContext.delete(duplicate)
//        }
//
//        // Salva o contexto após as remoções
//        try modelContext.save()
//    }
    
    private func addItem() {
        trainingProgrammingRouter.navigate(to: .trainingProgram)
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
