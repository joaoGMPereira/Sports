import DesignSystem
import SwiftUI

struct CreateTrainingsView: View {
    let trainingProgram: TrainingProgram
    @Binding var uniqueSetPlan: SetPlan?
    @Binding var uniqueSetPlanEnabled: Bool
    init(trainingProgram: TrainingProgram, uniqueSetPlan: Binding<SetPlan?>, uniqueSetPlanEnabled: Binding<Bool>) {
        self.trainingProgram = trainingProgram
        self._uniqueSetPlan = uniqueSetPlan
        self._uniqueSetPlanEnabled = uniqueSetPlanEnabled
    }
    
    var body: some View {
        ForEach(trainingProgram.orderedWorkoutSessions) { workoutSession in
            CreateTrainingView(workoutSession: workoutSession, uniqueSetPlan: $uniqueSetPlan, uniqueSetPlanEnabled: $uniqueSetPlanEnabled)
        }
        .listRowSeparator(.hidden)
    }
}

struct CreateTrainingView: View {
    @State private var workoutSession: WorkoutSession
    @State private var name: String
    @Binding var uniqueSetPlan: SetPlan?
    @Binding var uniqueSetPlanEnabled: Bool
    
    init(workoutSession: WorkoutSession, uniqueSetPlan: Binding<SetPlan?>, uniqueSetPlanEnabled: Binding<Bool>) {
        self.workoutSession = workoutSession
        self.name = workoutSession.name
        self._uniqueSetPlan = uniqueSetPlan
        self._uniqueSetPlanEnabled = uniqueSetPlanEnabled
    }
    
    
    var body: some View {
        Section(header: TextField("Treino", text: $name)) {
            if !workoutSession.workoutExercises.isEmpty {
                ForEach(workoutSession.workoutExercises.sorted(by: { $0.position ?? 0 < $1.position ?? 0})) { workoutExercise in
                    CreateExerciseView(workoutExercise: workoutExercise, uniqueSetPlan: $uniqueSetPlan, uniqueSetPlanEnabled: $uniqueSetPlanEnabled)
                }
                .onDelete(perform: delete)
            }
            DSFillButton(title: "Adicionar Exercício") {
                let biggerWorkoutExercisePosition = workoutSession.workoutExercises.sorted(by: { $0.position ?? 0 > $1.position ?? 0 }).first?.position ?? 0
                workoutSession.workoutExercises.append(.init(position: biggerWorkoutExercisePosition + 1))
            }
        }
    }
    
    func delete(at offsets: IndexSet) {
        workoutSession.workoutExercises.remove(atOffsets: offsets)
    }
}
