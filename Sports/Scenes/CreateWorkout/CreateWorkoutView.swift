import DesignSystem
import SwiftUI
import SwiftData

struct CreateWorkoutView: View {
    @State private var name: String = String()
    @State private var trainingDays: String = String()
    @State private var showDatePicker = false
    @State private var startDate = Date()
    @State private var workout: Workout?
    @State var showPopover = false
    @State private var series: String = String()
    @State private var minRep: String = String()
    @State private var maxRep: String = String()
    @State private var uniqueSerieEnabled = false
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @State private var uniqueSerie: Serie? = nil
    
    var body: some View {
        VStack {
            Form {
                workoutView
                if let workout {
                    CreateTrainingsView(
                        workout: workout,
                        uniqueSerie: $uniqueSerie,
                        uniqueSerieEnabled: $uniqueSerieEnabled
                    )
                }
            }
            if workout != nil {
                DSFillButton(title: "Criar treino") {
                    do {
                        try modelContext.save()
                        dismiss()
                    } catch {
                        print(error)
                    }
                }
            }
        }
        .onWillDisappear {
            if let workout, modelContext.hasChanges {
                modelContext.delete(workout)
            }
        }
        .navigationTitle("Criacao de Treino")
        .toolbar(.hidden, for: .tabBar)
        
        
    }
    
    var workoutView: some View {
        Section(header: Text("Dados Básicos")) {
            TextField("Nome", text: $name)
            TextField("Dias de treino", text: $trainingDays)
                .keyboardType(.numberPad)
            DatePicker(
                "Data de Inicio",
                selection: $startDate,
                displayedComponents: .date
            )
            uniqueSerieView
            Button("Criar Tipos de Execuções") {
                let convertedTrainingDays = Int(trainingDays) ?? 1
                let trainings: [Training] = Array(
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
                let workout = Workout(
                    title: name,
                    startDate: startDate,
                    trainings: trainings
                )
                self.workout = workout
                modelContext.insert(workout)
            }
            .disabled(uniqueSerieEnabled && uniqueSerie == nil)
            .buttonStyle(FillButtonStyle(color: Asset.primary.swiftUIColor, isEnabled: !(uniqueSerieEnabled && uniqueSerie == nil)))
        }
    }
    
    var uniqueSerieView: some View {
        Group {
            Toggle("Habilitar Serie unica", isOn: $uniqueSerieEnabled)
            if uniqueSerieEnabled {
                TextField("Series", text: $series)
                    .keyboardType(.numberPad)
                    .onChange(of: series) {
                        self.checkSerie()
                    }
                TextField("Repetições Minimas", text: $minRep)
                    .keyboardType(.numberPad)
                    .onChange(of: minRep) {
                        self.checkSerie()
                    }
                TextField("Repetições Máximas", text: $maxRep)
                    .keyboardType(.numberPad)
                    .onChange(of: maxRep) {
                        self.checkSerie()
                    }
            }
        }
    }
    
    func checkSerie() {
        if series.isNotEmpty && minRep.isNotEmpty && maxRep.isNotEmpty {
            uniqueSerie = .init(quantity: Int(series) ?? 0, minRep: Int(minRep) ?? 0, maxRep: Int(maxRep) ?? 0)
        } else {
            uniqueSerie = nil
        }
    }
    
    private func formattedDate() -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter.string(from: startDate)
    }
}
