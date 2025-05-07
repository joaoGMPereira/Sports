import SwiftUI
import SwiftData

struct TrainingsSummaryView: View {
    @Environment(\.modelContext) private var modelContext
    var workoutSessions: [WorkoutSession]
    //var exercisesPlans: [(exercises: [Exercise], setPlans: [SetPlanOld])] = [
//    self.exercisesPlans = workoutSessions.map { workoutSession in
//        return (fetchExercises(workoutSession.exercises.compactMap { $0.exerciseId }), fetchSetPlans(workoutSession.exercises.compactMap { $0.setPlanId }))
//    }
    init(workoutSessions: [WorkoutSession]) {
        self.workoutSessions = workoutSessions
    }
    
    var body: some View {
        ForEach(workoutSessions) { workoutSession in
            Text(workoutSession.name)
                .foregroundStyle(Color(uiColor: .secondaryLabel))
                .font(.caption)
            ForEach(workoutSession.workoutExercises) { workoutExercise in
                HStack {
                    if let name = workoutExercise.exercise?.name,
                       let quantity = workoutExercise.setPlan?.quantity,
                       let minRep = workoutExercise.setPlan?.minRep,
                       let maxRep = workoutExercise.setPlan?.maxRep {
                        Text(name)
                        Spacer()
                        Text(
                            "\(quantity) (\(minRep)x\(maxRep))"
                        )
                    }
                }
            }
        }
    }
    
    private func fetchExercises(_ ids: [(UUID)]) -> [Exercise] {
        let exercises = try? modelContext.fetch(
            FetchDescriptor<Exercise> (
                predicate: #Predicate { exercise in
                    ids.contains(exercise.id)
                }
            )
        )
        
        return exercises ?? []
    }
    
    private func fetchSetPlans(_ ids: [UUID]) -> [SetPlanOld] {
        let setPlans = try? modelContext.fetch(
            FetchDescriptor<SetPlanOld> (
                predicate: #Predicate { setPlan in
                    ids.contains(setPlan.id)
                }
            )
        )
        
        return setPlans ?? []
    }
}

