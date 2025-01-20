import DesignSystem
import SwiftData
import SwiftUI
struct CreateTrainingsView: View {
    let trainingProgram: TrainingProgram
    @Binding var uniqueSetPlan: SetPlan?
    init(trainingProgram: TrainingProgram, uniqueSetPlan: Binding<SetPlan?>) {
        self.trainingProgram = trainingProgram
        self._uniqueSetPlan = uniqueSetPlan
    }
    
    var body: some View {
        ForEach(trainingProgram.orderedWorkoutSessions) { workoutSession in
            CreateTrainingView(
                workoutSession: workoutSession,
                uniqueSetPlan: $uniqueSetPlan
            )
        }
        .listRowSeparator(.hidden)
    }
}

struct CreateTrainingView: View {
    @Environment(\.modelContext) private var modelContext
    @State private var workoutSession: WorkoutSession
    @State private var name: String
    @Binding var uniqueSetPlan: SetPlan?
    @Query private var items: [Exercise]
    
    init(
        workoutSession: WorkoutSession,
        uniqueSetPlan: Binding<SetPlan?>
    ) {
        self.workoutSession = workoutSession
        self.name = workoutSession.name
        self._uniqueSetPlan = uniqueSetPlan
    }
    
    
    var body: some View {
        Section(header: TextField("Treino", text: $name)) {
            if !workoutSession.workoutExercises.isEmpty {
                ForEach(workoutSession.workoutExercises.sorted(by: { $0.position ?? 0 < $1.position ?? 0})) { workoutExercise in
                    CreateExerciseView(
                        data: .init(
                            items: items.map {
                                $0.name
                            },
                            hasJustName: Binding<Bool>(
                                get: { uniqueSetPlan != nil },
                                set: { newValue in
                                    if !newValue {
                                        uniqueSetPlan = nil
                                    }
                                }
                            ),
                            name: workoutExercise.exercise?.name ?? String(),
                            setPlan: workoutExercise.setPlan
                        ),
                        completion: {
                            name,
                            selectedSetPlan in
                            workoutExercise.exercise = items.first(where: { $0.name == name }) ?? .init(name: name)
                            guard let uniqueSetPlan else {
                                workoutExercise.setPlan = selectedSetPlan
                                return
                            }
                            workoutExercise.setPlan = uniqueSetPlan
                        },
                        exerciseCreateCompletion: {
                            name in
                            if items.first(where: { $0.name == name }) == nil {
                                modelContext.insert(Exercise(name: name))
                                try? modelContext.save()
                            }
                        },
                        exerciseDeleteCompletion: {
                            name in
                            if let exercise = items.first(where: { $0.name == name }) {
                                modelContext.delete(exercise)
                                try? modelContext.save()
                            }
                        }
                    )
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
