import DesignSystem
import SwiftUI
import SwiftData
import SFSafeSymbols
import SwiftUIIntrospect

extension View {
    func hideKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}

struct UserKey: Hashable {
    let id: UUID
    let name: String
}

struct DetailTrainingProgramView: View {
    var trainingProgram: TrainingProgram
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @State private var isExpanded: Bool = true
    
    init(trainingProgram: TrainingProgram) {
        self.trainingProgram = trainingProgram
    }
    
    var body: some View {
        Form {
            Section("Treinos") {
                VStack(alignment: .leading, spacing: 4) {
                    Spacer(minLength: 4)
                    TrainingsSummaryView(workoutSessions: trainingProgram.orderedWorkoutSessions)
                    Spacer(minLength: 4)
                }
            }
            if trainingProgram.trainingLogs.count > 0 {
                Section("Histórico") {
                    HistoryExecutionsView(trainingProgram: trainingProgram)
                }
            }
            
            if trainingProgram.hasFinished == false {
                Section("Cadastrar Execução") {
                    AddExecutionView(trainingProgram: trainingProgram)
                }
            }
            Section("Meta dados") {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Data de criação")
                        .foregroundStyle(Color(uiColor: .secondaryLabel))
                        .font(.caption)
                    Text(trainingProgram.startDate, style: .date)
                        .listRowSeparator(.hidden)
                    if let endDate = trainingProgram.endDate {
                        Text("Data de encerramento")
                            .foregroundStyle(Color(uiColor: .secondaryLabel))
                            .font(.caption)
                        Text(endDate, style: .date)
                            .listRowSeparator(.hidden)
                    } else {
                        DSFillButton(title: "Encerrar", color: .red) {
                            trainingProgram.hasFinished = true
                            trainingProgram.endDate = .now
                            
                            do {
                                try modelContext.save()
                            } catch {
                                print("Failed to encerrar: \(error)")
                            }
                        }
                    }
                }
            }
        }
        .navigationTitle(trainingProgram.title)
        .toolbar(.hidden, for: .tabBar)
        .onAppear {
            let workoutExercises = trainingProgram.workoutSessions.flatMap { $0.workoutExercises }
            for (index, workoutExercise) in (workoutExercises).enumerated() {
                if workoutExercise.position == nil {
                    workoutExercise.position = index
                }
            }

            try? modelContext.save()
            print(workoutExercises)
        }
    }
}
