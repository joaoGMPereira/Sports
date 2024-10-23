import DesignSystem
import SwiftUI

struct CreateTrainingsView: View {
    let workout: Workout
    @Binding var uniqueSerie: Serie?
    @Binding var uniqueSerieEnabled: Bool
    init(workout: Workout, uniqueSerie: Binding<Serie?>, uniqueSerieEnabled: Binding<Bool>) {
        self.workout = workout
        self._uniqueSerie = uniqueSerie
        self._uniqueSerieEnabled = uniqueSerieEnabled
    }
    
    var body: some View {
        ForEach(workout.trainings) { training in
            CreateTrainingView(training: training, uniqueSerie: $uniqueSerie, uniqueSerieEnabled: $uniqueSerieEnabled)
        }
    }
}

struct CreateTrainingView: View {
    @State private var training: Training
    @State private var name: String
    @Binding var uniqueSerie: Serie?
    @Binding var uniqueSerieEnabled: Bool
    
    init(training: Training, uniqueSerie: Binding<Serie?>, uniqueSerieEnabled: Binding<Bool>) {
        self.training = training
        self.name = training.name
        self._uniqueSerie = uniqueSerie
        self._uniqueSerieEnabled = uniqueSerieEnabled
    }
    
    
    var body: some View {
        Section(header: TextField("Treino", text: $name)) {
            if !training.exercises.isEmpty {
                ForEach(training.exercises) { exercise in
                    CreateExerciseView(exercise: exercise, uniqueSerie: $uniqueSerie, uniqueSerieEnabled: $uniqueSerieEnabled) { updated in
                        print(exercise)
                        print(updated)
                        print(training.exercises)
                    }
                }
                .onDelete(perform: delete)
            }
            DSFillButton(title: "Adicionar Exercício") {
                training.exercises.append(.init())
            }
        }
    }
    
    func delete(at offsets: IndexSet) {
        training.exercises.remove(atOffsets: offsets)
    }
}
