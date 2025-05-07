import SwiftUI
import Zenith

enum WorkoutPlanRoute: Routable {
    case createWorkoutPlan
    case createWorkoutPlanOld
    case workoutPlans(_ trainingProgram: TrainingProgram)
    case workoutSession(_ session: WorkoutSession)
    case detail(_ trainingProgram: TrainingProgram)
    case edit(_ trainingProgram: EquatableBinding<TrainingProgram>)
    case commingSoonFeature
    
    var body: some View {
        switch self {
        case .createWorkoutPlan:
            CreateWorkoutPlanView()
        case .createWorkoutPlanOld:
            CreateTrainingProgramView()
        case let .workoutPlans(trainingProgram):
            WorkoutPlansView(trainingProgram: trainingProgram)
        case let .workoutSession(session):
            WorkoutSessionView(session: session)
        case let .detail(trainingProgram):
            DetailTrainingProgramView(trainingProgram: trainingProgram)
        case let .edit(trainingProgram):
            EditTrainingProgramView(trainingProgram: trainingProgram.wrappedValue)
        case .commingSoonFeature:
            CommingSoonFeatureView()
        }
    }
}
