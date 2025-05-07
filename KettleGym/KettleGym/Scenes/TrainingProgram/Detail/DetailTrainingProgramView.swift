import Zenith
import ZenithCoreInterface
import SwiftUI
import SwiftData
import SFSafeSymbols
import SwiftUIIntrospect

struct DetailTrainingProgramView: View, BaseThemeDependencies {
    @State var trainingProgram: TrainingProgram
    
    @Dependency(\.themeConfigurator) public var themeConfigurator: any ThemeConfiguratorProtocol
    @Environment(Router<WorkoutPlanRoute>.self) var workoutPlanRoute
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @State private var isExpanded: Bool = true
    @State private var shouldResetView = false
    
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
                    AddExecutionView(
                        trainingProgram: $trainingProgram,
                        shouldResetView: $shouldResetView
                    )
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
        .toolbar {
            if trainingProgram.hasFinished == false {
                ToolbarItem {
                    Button(action: editTrainingProgram) {
                        Label("Edit", systemImage: SFSymbol.pencil.rawValue)
                    }
                }
            }
        }
        .navigationTitle(trainingProgram.title)
        .toolbar(.hidden, for: .tabBar)
        .onAppear {
            shouldResetView = true
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                shouldResetView = false
            }
        }
        .onChange(of: trainingProgram) {
            print(trainingProgram)
        }
    }
    
    func editTrainingProgram() {
        workoutPlanRoute.navigate(to: .edit(.init(wrappedValue: $trainingProgram)))
    }
}
