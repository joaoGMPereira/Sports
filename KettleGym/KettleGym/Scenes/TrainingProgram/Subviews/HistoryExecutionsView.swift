import SwiftUI

struct Item: Identifiable {
    let id = UUID()
    let title: String
    let trainingLogs: [TrainingLog]
    var isExpanded: Bool = false
}

struct HistoryExecutionsView: View {
    var trainingProgram: TrainingProgram
    @State private var trainingLogItems: [Item] = []
    
    init(trainingProgram: TrainingProgram) {
        self.trainingProgram = trainingProgram
        self._trainingLogItems = State(initialValue: groupExecutionsByUser(trainingProgram: trainingProgram))
    }
    var body: some View {
            ForEach($trainingLogItems) { $item in
                DisclosureGroup(item.title, isExpanded: $item.isExpanded) {
                    VStack(alignment: .leading, spacing: 4) {
                        ForEach(item.trainingLogs) { itemExecution in
                            Text(itemExecution.scheduledTraining.name)
                                .font(.subheadline)
                            Text("Exercícios")
                                .foregroundStyle(Color(uiColor: .secondaryLabel))
                                .font(.caption)
                            ForEach(itemExecution.scheduledTraining.performedExercises) { performedExercise in
                                Text(performedExercise.name)
                                if let quantity = performedExercise.setPlan.quantity,
                                   let minRep = performedExercise.setPlan.minRep,
                                   let maxRep = performedExercise.setPlan.maxRep {
                                    Text(
                                        "\(quantity) (\(minRep)x\(maxRep))"
                                    )
                                }
                                ForEach(performedExercise.exerciseSets) { trainingLog in
                                    Text(
                                        "Peso: \(trainingLog.weight), Rep: \(trainingLog.reps)"
                                    )
                                }
                            }
                            Text("Feito: \(formattedDate(itemExecution.date))")
                                .foregroundStyle(Color(uiColor: .secondaryLabel))
                                .font(.caption)
                                .padding(.bottom, 8)
                        }
                    }
                }
                .listRowSeparator(.hidden)
            }
            .onChange(
                of: trainingProgram.trainingLogs,
                {
                    trainingLogItems = groupExecutionsByUser(trainingProgram: trainingProgram)
                }
            )
    }
    
    func groupExecutionsByUser(trainingProgram: TrainingProgram) -> [Item] {
        // Group trainingLogs by user using Dictionary with UserKey
        let groupedExecutions = Dictionary(grouping: trainingProgram.trainingLogs, by: { UserKey(id: $0.user.id, name: $0.user.name) })

        // Map the grouped trainingLogs into an array of Item
        let items: [Item] = groupedExecutions.map { (key, trainingLogs) in
            return Item(title: key.name, trainingLogs: trainingLogs.sorted(by: { $0.date > $1.date }))
        }
        
        return items
    }
    
    private func formattedDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter.string(from: date)
    }
}
