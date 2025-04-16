import SwiftUI
import Zenith

enum TrainingProgramRoute: Routable {
    case trainingProgram
    case workoutPlans(_ trainingProgram: TrainingProgram)
    case workoutSession(_ session: WorkoutSession)
    case detail(_ trainingProgram: TrainingProgram)
    case edit(_ trainingProgram: EquatableBinding<TrainingProgram>)
    
    var body: some View {
        switch self {
        case .trainingProgram:
            CreateTrainingProgramView()
        case let .workoutPlans(trainingProgram):
            WorkoutPlansView(trainingProgram: trainingProgram)
        case let .workoutSession(session):
            WorkoutSessionView(session: session)
        case let .detail(trainingProgram):
            DetailTrainingProgramView(trainingProgram: trainingProgram)
        case let .edit(trainingProgram):
            EditTrainingProgramView(trainingProgram: trainingProgram.wrappedValue)
        }
    }
}
