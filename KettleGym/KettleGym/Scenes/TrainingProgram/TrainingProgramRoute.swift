import SwiftUI
import Zenith
import ZenithCore

enum TrainingProgramRoute: Routable {
    case trainingProgram
    case detail(_ trainingProgram: TrainingProgram)
    case edit(_ trainingProgram: EquatableBinding<TrainingProgram>)
    
    var body: some View {
        switch self {
        case .trainingProgram:
            CreateTrainingProgramView()
        case let .detail(trainingProgram):
            DetailTrainingProgramView(trainingProgram: trainingProgram)
        case let .edit(trainingProgram):
            EditTrainingProgramView(trainingProgram: trainingProgram.wrappedValue)
        }
    }
}
