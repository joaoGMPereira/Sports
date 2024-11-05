import DesignSystem
import SwiftUI
import SwiftData

struct CreateTrainingProgramView: View {
    @State private var name: String = String()
    @State private var trainingDays: String = String()
    @State private var showDatePicker = true
    @State private var sheetModel = GridSheetModel(items: [])
    @State private var startDate = Date()
    @State private var trainingProgram: TrainingProgram?
    @State var showPopover = false
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @State private var uniqueSetPlan: SetPlan? = nil
    @Environment(ToastModel.self) var toast
    @Query private var fetchedSetPlans: [SetPlan]
    
    var body: some View {
        VStack {
            Form {
                trainingProgramView
                if let trainingProgram {
                    CreateTrainingsView(
                        trainingProgram: trainingProgram,
                        uniqueSetPlan: $uniqueSetPlan
                    )
                }
            }
            if trainingProgram != nil {
                DSFillButton(title: "Criar treino") {
                    let showExercisesError = trainingProgram?.hasExercisesEmpty ?? true
                    if showExercisesError {
                        toast.showError(message: "Adicione pelo menos 1 exercicio por treino")
                    }
                    if toast.isPresented == false {
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
        .gridSheet(
            model: $sheetModel,
            setPlanCreated: { quantity, minRep, maxRep in
                guard let quantity = Int(quantity), let minRep = Int(minRep), let maxRep = Int(maxRep) else { return }
                let selectedSetPlan = SetPlan(quantity: quantity, minRep: minRep, maxRep: maxRep)
                if let currentTrainingProgram = self.trainingProgram {
                    modelContext.delete(currentTrainingProgram)
                }
                modelContext.insert(selectedSetPlan)
                try? modelContext.save()
                sheetModel.set(items: fetchedSetPlans.compactMap { $0.name })
                let trainingProgram = TrainingProgram(
                    title: name,
                    startDate: startDate,
                    workoutSessions: []
                )
                self.trainingProgram = trainingProgram
            },
            setPlanRemoved: { setPlan in
                if let setPlan = self.fetchedSetPlans.first(where: { $0.name == setPlan }) {
                    if setPlan.name == uniqueSetPlan?.name {
                        uniqueSetPlan = nil
                    }
                    if let currentTrainingProgram = self.trainingProgram {
                        modelContext.delete(currentTrainingProgram)
                    }
                    let trainingProgram = TrainingProgram(
                        title: name,
                        startDate: startDate,
                        workoutSessions: []
                    )
                    self.trainingProgram = trainingProgram
                    modelContext.delete(setPlan)
                    try? modelContext.save()
                    sheetModel.set(items: fetchedSetPlans.compactMap { $0.name })
                }
            }) { selectedSetPlan in
                self.uniqueSetPlan = self.fetchedSetPlans.first(where: { $0.name == selectedSetPlan })
                self.sheetModel.dismiss()
                updateTrainingProgram()
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
            .disabled(trainingDays.isEmpty || name.isEmpty)
            .buttonStyle(
                FillButtonStyle(
                    color: Asset.primary.swiftUIColor,
                    isEnabled: !(trainingDays.isEmpty ||  name.isEmpty)
                )
            )
        }
    }
    
    var uniqueSetPlanView: some View {
        Group {
            Button {
                sheetModel.set(items: fetchedSetPlans.compactMap { $0.name })
            } label: {
                HStack {
                    Text("Escolher Série unica")
                    Image(systemSymbol: .questionmarkCircle)
                        .onTapGesture {
                            toast.showInfo(
                                title:"Informativo",
                                message: "Está série será aplicada para todos os exercícios do treino",
                                autoDismiss: false
                            )
                        }
                    Spacer()
                    if let name = uniqueSetPlan?.name {
                        ChipView(label: name, isSelected: false, style: .small) { name in
                            uniqueSetPlan = nil
                            let trainingProgram = TrainingProgram(
                                title: name,
                                startDate: startDate,
                                workoutSessions: []
                            )
                            self.trainingProgram = trainingProgram
                            //updateTrainingProgram()
                        }
                    }
                    Image(systemSymbol: .chevronRight)
                        .foregroundColor(.gray)
                }
            }
            .foregroundStyle(Color.primary)
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
}
