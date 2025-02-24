import SwiftUI
import SwiftData
import Zenith
import ZenithCore

struct EditTrainingProgramView: View {
    @State private var name: String = String()
    @State private var trainingDays: String = String()
    @State private var startDate = Date()
    @Binding private var trainingProgram: TrainingProgram
    @State private var changedTrainingProgram: TrainingProgram
    @State var showPopover = false
    @State var showAlert = false
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @Environment(ToastModel.self) var toast
    
    init(
        trainingProgram: Binding<TrainingProgram>
    ) {
        self._trainingProgram = trainingProgram
        self._changedTrainingProgram = State(initialValue: trainingProgram.wrappedValue)
        self._name = State(initialValue: trainingProgram.wrappedValue.title)
        self._trainingDays = State(initialValue: "\(trainingProgram.wrappedValue.workoutSessions.count)")
        self._startDate = State(initialValue: trainingProgram.wrappedValue.startDate)
    }
    
    var body: some View {
        VStack {
            Form {
                trainingProgramView
                CreateTrainingsView(
                    trainingProgram: changedTrainingProgram,
                    uniqueSetPlan: .constant(nil)
                )
            }
            DSFillButton(title: "Atualizar o treino") {
                update()
            }
            .padding([.horizontal, .bottom], 20)
        }
        .navigationTitle(changedTrainingProgram.title)
        .toolbar(.hidden, for: .tabBar)
        .alert("Deseja continuar?", isPresented: $showAlert) {
            Button("Adicionar") {
                addRemainingTrainingProgram()
            }
            Button("Sobreescrever", role: .destructive) {
                overrideTrainingProgram()
            }
        } message: {
            Text("Fique atento a escolha, caso queira completar os Dias de treino escolha **Adicionar**")
        }
        .onWillDisappear {
            if modelContext.hasChanges {
                modelContext.rollback()
            }
        }
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
            Button("Atualizar Tipos de Execuções") {
                askForChange()
            }
            .disabled(
                trainingDays.isEmpty ||  name.isEmpty
            )
            .buttonStyle(
                FillButtonStyle(
                    color: Asset.primary.swiftUIColor,
                    isEnabled: !(
                        trainingDays.isEmpty ||  name.isEmpty
                    )
                )
            )
        }
    }
    
    func askForChange() {
        showAlert = true
    }
    
    func overrideTrainingProgram() {
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
        
        let trainingProgram = TrainingProgram(
            title: name,
            startDate: startDate,
            workoutSessions: workoutSessions
        )

        modelContext.insert(trainingProgram)
        self.changedTrainingProgram = trainingProgram
    }
    
    func addRemainingTrainingProgram() {
        guard let convertedTrainingDays = Int(trainingDays), name.isNotEmpty else {
            return
        }
        let remainingDays = convertedTrainingDays - trainingProgram.workoutSessions.count
        if remainingDays <= 0 {
            toast.showError(message: "Quantidade de dias menor ou igual que o atual: \(trainingProgram.workoutSessions.count)")
            return
        }
        
        let newWorkoutSessions: [WorkoutSession] = Array(
            trainingProgram.workoutSessions.count..<trainingProgram.workoutSessions.count+remainingDays
        )
            .map {
                day in .init(
                    name: day.convertToTraningName
                )
            }
            .sorted { first, second in
                first.name < second.name
            }
        
        
        let trainingProgram = TrainingProgram(
            title: name,
            startDate: startDate,
            workoutSessions: trainingProgram.workoutSessions + newWorkoutSessions
        )

        self.changedTrainingProgram = trainingProgram
    }
    
    func update() {
        let showExercisesError = changedTrainingProgram.hasExercisesEmpty
        changedTrainingProgram.title = name
        changedTrainingProgram.startDate = startDate
        if showExercisesError {
            toast.showError(message: "Adicione pelo menos 1 exercicio por treino")
            return
        }
        do {
            trainingProgram.title = changedTrainingProgram.title
            trainingProgram.workoutSessions = changedTrainingProgram.workoutSessions
            trainingProgram.startDate = changedTrainingProgram.startDate
            try modelContext.save()
            dismiss()
        } catch {
            print(error)
        }
    }
}
