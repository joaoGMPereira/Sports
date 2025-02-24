import Zenith
import ZenithCore
import SwiftUI
import SwiftData

struct AddExecutionView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(ToastModel.self) var toast
    @Binding var trainingProgram: TrainingProgram
    @Binding var shouldResetView: Bool
    @State var selectedTraining: ScheduledTraining?
    @State var user: String = String()
    @State var selectedUser: User?
    @Query private var users: [User] = []
    @State private var selectedChip: String? = nil
    @State private var executorSheetModel = GridSheetModel(items: [])
    
    var body: some View {
        Group {
            SelectionView(title: "Escolher Executor", selectedTitle: $user) {
                executorSheetModel.set(items: users.map { $0.name })
            }
            .padding(.top, 4)
            .gridSheet(
                title: "Criar Executor",
                model: $executorSheetModel,
                created: { user in
                    self.user = user
                    self.executorSheetModel.dismiss()
                    if self.users.first(where: { $0.name == user }) == nil {
                        let selectedUser = User(name: user)
                        self.selectedUser = selectedUser
                        modelContext.insert(selectedUser)
                        do {
                            try modelContext.save()
                        } catch {
                            print("Failed to save user: \(error)")
                        }
                        executorSheetModel.items.append(user)
                    }
                },
                removed: { user in
                    if let user = self.users.first(where: { $0.name == user }) {
                        if user.name == self.user {
                            self.user = ""
                            self.selectedUser = nil
                        }
                        modelContext.delete(user)
                        do {
                            try modelContext.save()
                        } catch {
                            print("Failed to save user: \(error)")
                        }
                        executorSheetModel.items.removeAll(where: { $0 == user.name })
                    }
                }) { user in
                    self.user = user
                    if let foundUser = self.users.first(where: { $0.name == user }) {
                        self.selectedUser = foundUser
                    }
                    self.executorSheetModel.dismiss()
                }
            ChipGridView(
                chips: .constant(trainingProgram.workoutSessions.map {
                    $0.name
                }),
                chipSelected: $selectedChip,
                isSelectable: true) { training in
                if let selectedTraining = trainingProgram.workoutSessions.first(where: { $0.name == training }) {
                    let trainingLogSelectedTraining = ScheduledTraining(
                        name: selectedTraining.name,
                        performedExercises: selectedTraining.workoutExercises.compactMap {
                            if let exercise = $0.exercise, let setPlan = $0.setPlan {
                                return .init(
                                    name: exercise.name,
                                    setPlan: setPlan,
                                    exerciseSets: []
                                )
                            }
                            return nil
                        }
                    )
                    self.modelContext.insert(trainingLogSelectedTraining)
                    self.selectedTraining = trainingLogSelectedTraining
                } else {
                    self.selectedTraining = nil
                }
            }
            .onChange(of: shouldResetView) {
                if shouldResetView {
                    selectedTraining = nil
                    selectedChip = nil
                }
            }
            if let selectedTraining {
                TrainingExecutionView(
                    scheduledTraining: .init(
                        get: {
                            return selectedTraining
                        },
                        set: {
                            _ in
                        }),
                    user: $selectedUser
                )
            }
            DSFillButton(title: "Salvar") {
                guard let selectedUser else {
                    toast.showError(message: "Escolha um executor")
                    return
                }
                if let selectedTraining, selectedTraining.hasNotSavedExecutions() == false {
                    trainingProgram.trainingLogs.append(
                        .init(
                            date: .now,
                            user: selectedUser,
                            scheduledTraining: selectedTraining
                        )
                    )
                    do {
                        try modelContext.save()
                    } catch {
                        print("Failed to save trainingLog: \(error)")
                    }
                }
                if selectedTraining == nil {
                    toast.showError(message: "Escolha seu treino")
                    return
                }
                
                if selectedTraining?.hasNotSavedExecutions() == true {
                    toast.showError(message: "Preencha todas suas execuções")
                    return
                }
            }
            .onChange(of: trainingProgram) {
                print(trainingProgram)
            }
        }
        .listRowSeparator(.hidden)
    }
}
