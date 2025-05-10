import Foundation
import SwiftData

typealias TrainingProgram = TrainingProgramSchemaV2.TrainingProgram
typealias SetPlanOld = TrainingProgramSchemaV2.SetPlanOld
typealias Exercise = TrainingProgramSchemaV2.Exercise
typealias WorkoutSession = TrainingProgramSchemaV2.WorkoutSession
typealias WorkoutExercise = TrainingProgramSchemaV2.WorkoutExercise
typealias TrainingLog = TrainingProgramSchemaV2.TrainingLog
typealias ScheduledTraining = TrainingProgramSchemaV2.ScheduledTraining
typealias PerformedExercise = TrainingProgramSchemaV2.PerformedExercise
typealias User = TrainingProgramSchemaV2.User
typealias ExerciseSet = TrainingProgramSchemaV2.ExerciseSet

enum TrainingProgramMigrationPlan: @preconcurrency SchemaMigrationPlan {
    static var schemas: [any VersionedSchema.Type] {
        [TrainingProgramSchemaV1.self, TrainingProgramSchemaV2.self]
    }
    
    @MainActor
    static var stages: [MigrationStage] {
        [migrateV1toV2]
    }
    
    @MainActor static let migrateV1toV2 = MigrationStage.lightweight(
        fromVersion: TrainingProgramSchemaV1.self,
       toVersion: TrainingProgramSchemaV2.self)
}

enum TrainingProgramSchemaV2: @preconcurrency VersionedSchema {
    @MainActor static let versionIdentifier = Schema.Version(3, 0, 0)
    
    static var models: [any PersistentModel.Type] {
        return [TrainingProgram.self, User.self, TrainingLog.self, WorkoutSession.self, WorkoutExercise.self, Exercise.self, ExerciseSet.self, SetPlanOld.self, ScheduledTraining.self, PerformedExercise.self, CommingSoon.self]
    }
    
    @Model
    final class TrainingProgram: CustomStringConvertible {
        @Attribute(.unique)
        var id: UUID?
        var title: String
        var startDate: Date
        var endDate: Date?
        var workoutSessions: [WorkoutSession] = []
        var trainingLogs: [TrainingLog] = []
        var hasFinished: Bool = false
        
        var orderedWorkoutSessions: [WorkoutSession] {
            workoutSessions.sorted { first, second in
                first.name < second.name
            }
        }
        
        var hasExercisesEmpty: Bool {
            workoutSessions.isEmpty || workoutSessions.contains(where: { $0.workoutExercises.isEmpty || $0.workoutExercises.contains(where: { $0.setPlan == nil }) })
        }
        
        init(title: String, startDate: Date, endDate: Date? = nil, workoutSessions: [WorkoutSession], hasFinished: Bool = false) {
            self.id = .init()
            self.title = title
            self.startDate = startDate
            self.endDate = endDate
            self.workoutSessions = workoutSessions
            self.hasFinished = hasFinished
        }
        
        var description: String {
            return "TrainingProgram(id: \(id), title: \(title), startDate: \(startDate), endDate: \(endDate), workoutSessions: \(workoutSessions), trainingLogs: \(trainingLogs), hasFinished: \(hasFinished))"
        }
    }
    
    @Model
    final class User: CustomStringConvertible {
        @Attribute(.unique)
        var id: UUID
        @Attribute(.unique)
        var name: String
        
        init(name: String) {
            self.id = .init()
            self.name = name
        }
        
        var description: String {
            return "User(id: \(id), name: \(name))"
        }
    }
    
    @Model
    final class TrainingLog: CustomStringConvertible {
        @Attribute(.unique)
        var id: UUID
        var date: Date
        var user: User
        var scheduledTraining: ScheduledTraining
        
        var trainingProgram: TrainingProgram?
        
        init(date: Date, user: User, scheduledTraining: ScheduledTraining) {
            self.id = .init()
            self.date = date
            self.user = user
            self.scheduledTraining = scheduledTraining
        }
        
        var description: String {
            return "TrainingLog(id: \(id), date: \(date), user: \(user), scheduledTraining: \(scheduledTraining))"
        }
    }
    
    @Model
    final class ScheduledTraining: CustomStringConvertible {
        @Attribute(.unique)
        var id: UUID?
        var name: String
        var performedExercises: [PerformedExercise] = []
        
        var trainingLog: TrainingLog?
        
        func hasNotSavedExecutions() -> Bool {
            performedExercises.contains(where: { $0.exerciseSets.isEmpty })
        }
        
        init(name: String = String(), performedExercises: [PerformedExercise] = []) {
            self.id = .init()
            self.name = name
            self.performedExercises = performedExercises
        }
        
        var description: String {
            return "WorkoutSession(id: \(id), name: \(name), performedExercises: \(performedExercises)"
        }
    }
    
    @Model
    final class PerformedExercise: CustomStringConvertible {
        @Attribute(.unique)
        var id: UUID
        var name: String
        var setPlan: SetPlanOld
        var exerciseSets: [ExerciseSet]
        
        init(name: String = String(), setPlan: SetPlanOld = .init(), exerciseSets: [ExerciseSet] = []) {
            self.id = .init()
            self.name = name
            self.setPlan = setPlan
            self.exerciseSets = exerciseSets
        }
        
        var description: String {
            return "PerformedExercise(id: \(id), name: \(name), setPlan: \(setPlan), exerciseSets: \(exerciseSets)"
        }
    }

    @Model
    final class ExerciseSet: CustomStringConvertible {
        @Attribute(.unique)
        var id: UUID
        var weight: Int
        var reps: Int
        var exercise: Exercise?
        
        init(weight: Int, reps: Int) {
            self.id = .init()
            self.weight = weight
            self.reps = reps
        }
        
        var description: String {
            return "ExerciseSet(id: \(id), weight: \(weight), reps: \(reps))"
        }
    }


    @Model
    final class WorkoutSession: CustomStringConvertible {
        @Attribute(.unique)
        var id: UUID
        var name: String
        var workoutExercises: [WorkoutExercise] = []
        
        var trainingProgram: TrainingProgram?
        var trainingLog: TrainingLog?
        
        init(name: String = String(), workoutExercises: [WorkoutExercise] = []) {
            self.id = .init()
            self.name = name
            self.workoutExercises = workoutExercises
        }
        
        var description: String {
            return "WorkoutSession(id: \(id), name: \(name), workoutExercises: \(workoutExercises)"
        }
    }
    
    @Model
    final class WorkoutExercise: CustomStringConvertible {
        @Attribute(.unique)
        var id: UUID
        var position: Int?
        var exercise: Exercise?
        var setPlan: SetPlanOld?
        
        init(position: Int, exercise: Exercise? = nil, setPlan: SetPlanOld? = nil) {
            self.id = .init()
            self.position = position
            self.exercise = exercise
            self.setPlan = setPlan
        }
        
        var description: String {
            return "WorkoutExercise(id: \(id), position: \(position), exercise: \(exercise), setPlan: \(setPlan)"
        }
    }


    @Model
    final class Exercise: CustomStringConvertible {
        @Attribute(.unique)
        var id: UUID
        var name: String
        
        init(name: String = String()) {
            self.id = .init()
            self.name = name
        }
        
        var description: String {
            return "Exercise(id: \(id), name: \(name)"
        }
    }

    
    @Model
    final class SetPlanOld: CustomStringConvertible {
        @Attribute(.unique)
        var id: UUID
        var quantity: Int?
        var minRep: Int?
        var maxRep: Int?
        
        var name: String? {
            guard let quantity, let minRep, let maxRep else { return nil }
            return "\(quantity) (\(minRep)x\(maxRep))"
        }
        
        var exercise: Exercise?
        
        init(quantity: Int? = nil, minRep: Int? = nil, maxRep: Int? = nil) {
            self.id = .init()
            self.quantity = quantity
            self.minRep = minRep
            self.maxRep = maxRep
        }
        
        var description: String {
            return "Serie(id: \(id), quantity: \(String(describing: quantity)), minRep: \(String(describing: minRep)), maxRep: \(String(describing: maxRep)))"
        }
    }
}

enum TrainingProgramSchemaV1: @preconcurrency VersionedSchema {
    @MainActor
    static let versionIdentifier = Schema.Version(2, 0, 0)
    
    static var models: [any PersistentModel.Type] {
        return [TrainingProgram.self, User.self, TrainingLog.self, WorkoutSession.self, WorkoutExercise.self, Exercise.self, ExerciseSet.self, SetPlanOld.self, ScheduledTraining.self, PerformedExercise.self, CommingSoon.self]
    }
    
    @Model
    final class TrainingProgram: CustomStringConvertible {
        @Attribute(.unique)
        var id: UUID?
        var title: String
        var startDate: Date
        var endDate: Date?
        var workoutSessions: [WorkoutSession] = []
        var trainingLogs: [TrainingLog] = []
        var hasFinished: Bool = false
        
        var orderedWorkoutSessions: [WorkoutSession] {
            workoutSessions.sorted { first, second in
                first.name < second.name
            }
        }
        
        var hasExercisesEmpty: Bool {
            workoutSessions.isEmpty || workoutSessions.contains(where: { $0.workoutExercises.isEmpty })
        }
        
        init(title: String, startDate: Date, endDate: Date? = nil, workoutSessions: [WorkoutSession], hasFinished: Bool = false) {
            self.id = .init()
            self.title = title
            self.startDate = startDate
            self.endDate = endDate
            self.workoutSessions = workoutSessions
            self.hasFinished = hasFinished
        }
        
        var description: String {
            return "TrainingProgram(id: \(id), title: \(title), startDate: \(startDate), endDate: \(endDate), workoutSessions: \(workoutSessions), trainingLogs: \(trainingLogs), hasFinished: \(hasFinished))"
        }
    }
    
    @Model
    final class User: CustomStringConvertible {
        @Attribute(.unique)
        var id: UUID
        @Attribute(.unique)
        var name: String
        
        init(name: String) {
            self.id = .init()
            self.name = name
        }
        
        var description: String {
            return "User(id: \(id), name: \(name))"
        }
    }
    
    @Model
    final class TrainingLog: CustomStringConvertible {
        @Attribute(.unique)
        var id: UUID
        var date: Date
        var user: User
        var scheduledTraining: ScheduledTraining
        
        var trainingProgram: TrainingProgram?
        
        init(date: Date, user: User, scheduledTraining: ScheduledTraining) {
            self.id = .init()
            self.date = date
            self.user = user
            self.scheduledTraining = scheduledTraining
        }
        
        var description: String {
            return "TrainingLog(id: \(id), date: \(date), user: \(user), scheduledTraining: \(scheduledTraining))"
        }
    }
    
    @Model
    final class ScheduledTraining: CustomStringConvertible {
        @Attribute(.unique)
        var id: UUID?
        var name: String
        var performedExercises: [PerformedExercise] = []
        
        var trainingLog: TrainingLog?
        
        func hasEmptyExecutions() -> Bool {
            performedExercises.contains(where: { $0.exerciseSets.isEmpty })
        }
        
        init(name: String = String(), performedExercises: [PerformedExercise] = []) {
            self.id = .init()
            self.name = name
            self.performedExercises = performedExercises
        }
        
        var description: String {
            return "WorkoutSession(id: \(id), name: \(name), performedExercises: \(performedExercises)"
        }
    }
    
    @Model
    final class PerformedExercise: CustomStringConvertible {
        @Attribute(.unique)
        var id: UUID
        var name: String
        var setPlan: SetPlanOld
        var exerciseSets: [ExerciseSet]
        
        init(name: String = String(), setPlan: SetPlanOld = .init(), exerciseSets: [ExerciseSet] = []) {
            self.id = .init()
            self.name = name
            self.setPlan = setPlan
            self.exerciseSets = exerciseSets
        }
        
        var description: String {
            return "PerformedExercise(id: \(id), name: \(name), setPlan: \(setPlan), exerciseSets: \(exerciseSets)"
        }
    }

    @Model
    final class ExerciseSet: CustomStringConvertible {
        @Attribute(.unique)
        var id: UUID
        var weight: Int
        var reps: Int
        var exercise: Exercise?
        
        init(weight: Int, reps: Int) {
            self.id = .init()
            self.weight = weight
            self.reps = reps
        }
        
        var description: String {
            return "ExerciseSet(id: \(id), weight: \(weight), reps: \(reps))"
        }
    }


    @Model
    final class WorkoutSession: CustomStringConvertible {
        @Attribute(.unique)
        var id: UUID
        var name: String
        var workoutExercises: [WorkoutExercise] = []
        
        var trainingProgram: TrainingProgram?
        var trainingLog: TrainingLog?
        
        init(name: String = String(), workoutExercises: [WorkoutExercise] = []) {
            self.id = .init()
            self.name = name
            self.workoutExercises = workoutExercises
        }
        
        var description: String {
            return "WorkoutSession(id: \(id), name: \(name), workoutExercises: \(workoutExercises)"
        }
    }
    
    @Model
    final class WorkoutExercise: CustomStringConvertible {
        @Attribute(.unique)
        var id: UUID
        var exercise: Exercise?
        var setPlan: SetPlanOld?
        
        init(exercise: Exercise? = nil, setPlan: SetPlanOld? = nil) {
            self.id = .init()
            self.exercise = exercise
            self.setPlan = setPlan
        }
        
        var description: String {
            return "WorkoutExercise(id: \(id), exercise: \(exercise), setPlan: \(setPlan)"
        }
    }


    @Model
    final class Exercise: CustomStringConvertible {
        @Attribute(.unique)
        var id: UUID
        var name: String
        
        init(name: String = String()) {
            self.id = .init()
            self.name = name
        }
        
        var description: String {
            return "Exercise(id: \(id), name: \(name)"
        }
    }

    
    @Model
    final class SetPlanOld: CustomStringConvertible {
        @Attribute(.unique)
        var id: UUID
        var quantity: Int?
        var minRep: Int?
        var maxRep: Int?
        
        var exercise: Exercise?
        
        init(quantity: Int? = nil, minRep: Int? = nil, maxRep: Int? = nil) {
            self.id = .init()
            self.quantity = quantity
            self.minRep = minRep
            self.maxRep = maxRep
        }
        
        var description: String {
            return "Serie(id: \(id), quantity: \(String(describing: quantity)), minRep: \(String(describing: minRep)), maxRep: \(String(describing: maxRep)))"
        }
    }
}

extension Int {
    var convertToTraningName: String {
        var name = "Treino "
        switch self {
        case 0:
            name += "A"
        case 1:
            name += "B"
        case 2:
            name += "C"
        case 3:
            name += "D"
        case 4:
            name += "E"
        case 5:
            name += "F"
        case 6:
            name += "G"
        default:
            break
        }
        
        return name
    }
}

