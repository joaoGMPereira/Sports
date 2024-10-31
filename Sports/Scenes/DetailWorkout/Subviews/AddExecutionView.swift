import DesignSystem
import SwiftUI
import SwiftData


struct AddExecutionView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(ToastInfo.self) var toastInfo
    @State var trainingProgram: TrainingProgram
    @State var selectedTraining: ScheduledTraining?
    @State var user: String = String()
    @State var selectedUser: User?
    @State private var filteredUsers: [User] = []
    @Query private var users: [User] = []
    @State private var showUsersPopover = false
    var body: some View {
        Group {
            HStack {
                TextField("Executor", text: $user)
                    .introspect(.textField, on: .iOS(.v17, .v18)) { textField in
                        textField.inputAccessoryView = nil
                        textField.reloadInputViews()
                    }
                    .simultaneousGesture(
                        TapGesture()
                            .onEnded {
                                self.showUsersPopover = users.isNotEmpty
                            }
                    )
                    .onChange(of: user) {
                        self.applyFilter(with: user)
                    }
                    .onSubmit {
                        showUsersPopover = false
                        hideKeyboard()
                    }
                    .popover(
                        isPresented: $showUsersPopover,
                        attachmentAnchor: .point(
                            .top
                        )
                    ) {
                        ChipGridView(chips: (filteredUsers.isEmpty ? users : filteredUsers).map { $0.name }) { user in
                            self.user = user
                            self.selectedUser = users.first(where: { $0.name == user })
                            DispatchQueue.main.async {
                                showUsersPopover = false
                            }
                        }
                        .padding()
                        .frame(minWidth: 50, minHeight: 80, maxHeight: 400)
                        .presentationCompactAdaptation(.popover)
                    }
                Spacer()
                DSBorderedButton(
                    title: "+",
                    isEnabled: users.filter({ $0.name.localizedLowercase == user.localizedLowercase }).count == 0 ||
                    user.isEmpty,
                    horizontalPadding: 12
                ) {
                    if user.isNotEmpty, users.filter({ $0.name.localizedLowercase == user.localizedLowercase }).count == 0 {
                        let selectedUser = User(name: user)
                        self.selectedUser = selectedUser
                        modelContext.insert(selectedUser)
                        do {
                            try modelContext.save()
                        } catch {
                            print("Failed to save user: \(error)")
                        }
                        hideKeyboard()
                    }
                }
            }
            .padding(.top, 4)
            ChipGridView(chips: trainingProgram.workoutSessions.map { $0.name }, isSelectable: true) { training in
                showUsersPopover = false
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
                    toastInfo.showError(title: "escolha um executor")
                    return
                }
                if let selectedTraining, selectedTraining.hasEmptyExecutions() == false {
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
            }
        }
        .listRowSeparator(.hidden)
    }
    
    private func applyFilter(with text: String) {
        if text.isEmpty {
            filteredUsers = []
            showUsersPopover = false
        } else {
            filteredUsers = users.filter { $0.name.localizedCaseInsensitiveContains(text) }
            showUsersPopover = filteredUsers.count > 0
        }
    }
    
    private func formattedDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter.string(from: date)
    }
}
