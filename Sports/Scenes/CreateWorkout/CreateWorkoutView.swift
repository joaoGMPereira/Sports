import DesignSystem
import SwiftUI
import SwiftData

struct CreateTrainingProgramView: View {
    @State private var name: String = String()
    @State private var trainingDays: String = String()
    @State private var showDatePicker = true
    @State private var startDate = Date()
    @State private var trainingProgram: TrainingProgram?
    @State var showPopover = false
    @State private var setPlans: String = String()
    @State private var minRep: String = String()
    @State private var maxRep: String = String()
    @State private var uniqueSetPlanEnabled = false
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @State private var uniqueSetPlan: SetPlan? = nil
    @Environment(ToastInfo.self) var toastInfo
    
    var body: some View {
        VStack {
            Form {
                trainingProgramView
                if let trainingProgram {
                    CreateTrainingsView(
                        trainingProgram: trainingProgram,
                        uniqueSetPlan: $uniqueSetPlan,
                        uniqueSetPlanEnabled: $uniqueSetPlanEnabled
                    )
                }
            }
            if trainingProgram != nil {
                DSFillButton(title: "Criar treino") {
                    let showExercisesError = trainingProgram?.hasExercisesEmpty ?? true
                    if showExercisesError {
                        toastInfo.showError(title: "Adicione pelo menos 1 exercicio por treino")
                    }
                    if toastInfo.isPresented == false {
                        do {
                            try modelContext.save()
                            dismiss()
                        } catch {
                            print(error)
                        }
                    }
                }
                .padding([.horizontal, .bottom], 20)
            }
        }
        .onWillDisappear {
            if let trainingProgram, modelContext.hasChanges {
                modelContext.delete(trainingProgram)
            }
        }
        .navigationTitle("Criacao de Treino")
        .toolbar(.hidden, for: .tabBar)
        
        
    }
    
    var trainingProgramView: some View {
        Section(header: Text("Dados Básicos")) {
            TextField("Nome", text: $name)
                .listRowSeparator(.hidden)
            TextField("Dias de treino", text: $trainingDays)
                .listRowSeparator(.hidden)
                .keyboardType(.numberPad)
            DatePicker(
                "Data de Inicio",
                selection: $startDate,
                displayedComponents: .date
            )
            .listRowSeparator(.hidden)
            uniqueSetPlanView
            Button("Criar Tipos de Execuções") {
                guard let convertedTrainingDays = Int(trainingDays), name.isNotEmpty else {
                    return
                }
                let workoutSessions: [WorkoutSession] = Array(
                    0..<convertedTrainingDays
                )
                    .map {
                        day in .init(
                            name: day.convertToTraningName
                        )
                    }
                    .sorted { first, second in
                        first.name < second.name
                    }
                updateTrainingProgram(with: workoutSessions)
            }
            .disabled(
                (
                    uniqueSetPlanEnabled && uniqueSetPlan == nil
                ) || trainingDays.isEmpty ||  name.isEmpty
            )
            .buttonStyle(
                FillButtonStyle(
                    color: Asset.primary.swiftUIColor,
                    isEnabled: !(
                        (
                            uniqueSetPlanEnabled && uniqueSetPlan == nil
                        ) || trainingDays.isEmpty ||  name.isEmpty
                    )
                )
            )
        }
    }
    
    var uniqueSetPlanView: some View {
        Group {
            Toggle("Habilitar série unica", isOn: $uniqueSetPlanEnabled)
                .listRowSeparator(.hidden)
                .onChange(of: uniqueSetPlanEnabled) {
                    updateTrainingProgram()
                }
            if uniqueSetPlanEnabled {
                TextField("Series", text: $setPlans)
                    .keyboardType(.numberPad)
                    .onChange(of: setPlans) {
                        self.checkSetPlan()
                    }
                    .listRowSeparator(.hidden)
                TextField("Repetições Minimas", text: $minRep)
                    .keyboardType(.numberPad)
                    .onChange(of: minRep) {
                        self.checkSetPlan()
                    }
                    .listRowSeparator(.hidden)
                TextField("Repetições Máximas", text: $maxRep)
                    .keyboardType(.numberPad)
                    .onChange(of: maxRep) {
                        self.checkSetPlan()
                    }
                    .listRowSeparator(.hidden)
            }
        }
    }
    
    func updateTrainingProgram(with workoutSessions: [WorkoutSession] = []) {
        let trainingProgram = TrainingProgram(
            title: name,
            startDate: startDate,
            workoutSessions: workoutSessions
        )
        if let currentTrainingProgram = self.trainingProgram {
            modelContext.delete(currentTrainingProgram)
        }
        self.trainingProgram = trainingProgram
        modelContext.insert(trainingProgram)
    }
    
    func checkSetPlan() {
        if setPlans.isNotEmpty && minRep.isNotEmpty && maxRep.isNotEmpty {
            uniqueSetPlan = .init(quantity: Int(setPlans) ?? 0, minRep: Int(minRep) ?? 0, maxRep: Int(maxRep) ?? 0)
        } else {
            uniqueSetPlan = nil
        }
    }
    
    private func formattedDate() -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter.string(from: startDate)
    }
}
