import Foundation
import SwiftData

typealias Workout = WorkoutSchemaV2.Workout
typealias Serie = WorkoutSchemaV2.Serie
typealias Exercise = WorkoutSchemaV2.Exercise
typealias Training = WorkoutSchemaV2.Training
typealias Execution = WorkoutSchemaV2.Execution
typealias ExecutionTraining = WorkoutSchemaV2.ExecutionTraining
typealias ExecutionExercise = WorkoutSchemaV2.ExecutionExercise
typealias Owner = WorkoutSchemaV2.Owner
typealias SetExecution = WorkoutSchemaV2.SetExecution

enum WorkoutMigrationPlan: SchemaMigrationPlan {
    static var schemas: [any VersionedSchema.Type] {
        [WorkoutSchemaV1.self, WorkoutSchemaV2.self]
    }
    
    static var stages: [MigrationStage] {
        [migrateV1toV2]
    }
    
    static let migrateV1toV2 = MigrationStage.lightweight(
        fromVersion: WorkoutSchemaV1.self,
        toVersion: WorkoutSchemaV2.self
    )
}

enum WorkoutSchemaV2: VersionedSchema {
    static var versionIdentifier = Schema.Version(2, 0, 0)
    
    static var models: [any PersistentModel.Type] {
        return [Workout.self, Execution.self, Training.self, Exercise.self, SetExecution.self, Serie.self]
    }
    
    @Model
    final class Workout: CustomStringConvertible {
        @Attribute(.unique)
        var id: UUID
        var title: String
        var startDate: Date
        var endDate: Date?
        var trainings: [Training] = []
        var executions: [Execution] = []
        var hasFinished: Bool = false
        
        var orderedTrainings: [Training] {
            trainings.sorted { first, second in
                first.name < second.name
            }
        }
        
        init(title: String, startDate: Date, endDate: Date? = nil, trainings: [Training], hasFinished: Bool = false) {
            self.id = .init()
            self.title = title
            self.startDate = startDate
            self.endDate = endDate
            self.trainings = trainings
            self.hasFinished = hasFinished
        }
        
        var description: String {
            return "Workout(id: \(id), title: \(title), startDate: \(startDate), endDate: \(endDate), trainings: \(trainings), executions: \(executions), hasFinished: \(hasFinished))"
        }
    }
    
    @Model
    final class Owner: CustomStringConvertible {
        @Attribute(.unique)
        var id: UUID
        @Attribute(.unique)
        var name: String
        
        init(name: String) {
            self.id = .init()
            self.name = name
        }
        
        var description: String {
            return "Owner(id: \(id), name: \(name))"
        }
    }
    
    @Model
    final class Execution: CustomStringConvertible {
        @Attribute(.unique)
        var id: UUID
        var date: Date
        var owner: Owner
        var training: ExecutionTraining
        
        var workout: Workout?
        
        init(date: Date, owner: Owner, training: ExecutionTraining) {
            self.id = .init()
            self.date = date
            self.owner = owner
            self.training = training
        }
        
        var description: String {
            return "Execution(id: \(id), date: \(date), owner: \(owner), training: \(training))"
        }
    }
    
    @Model
    final class ExecutionTraining: CustomStringConvertible {
        @Attribute(.unique)
        var id: UUID
        var name: String
        var exercises: [ExecutionExercise] = []
        
        var execution: Execution?
        
        func hasEmptyExecutions() -> Bool {
            exercises.contains(where: { $0.executions.isEmpty })
        }
        
        init(name: String = String(), exercises: [ExecutionExercise] = []) {
            self.id = .init()
            self.name = name
            self.exercises = exercises
        }
        
        var description: String {
            return "Training(id: \(id), name: \(name), exercises: \(exercises)"
        }
    }
    
    @Model
    final class ExecutionExercise: CustomStringConvertible {
        @Attribute(.unique)
        var id: UUID
        var name: String
        var serie: Serie
        var executions: [SetExecution]
        
        init(name: String = String(), serie: Serie = .init(), executions: [SetExecution] = []) {
            self.id = .init()
            self.name = name
            self.serie = serie
            self.executions = executions
        }
        
        var description: String {
            return "Exercise(id: \(id), name: \(name), serie: \(serie), executions: \(executions)"
        }
    }

    @Model
    final class SetExecution: CustomStringConvertible {
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
            return "SetExecution(id: \(id), weight: \(weight), reps: \(reps))"
        }
    }


    @Model
    final class Training: CustomStringConvertible {
        @Attribute(.unique)
        var id: UUID
        var name: String
        var exercises: [Exercise] = []
        
        var workout: Workout?
        var execution: Execution?
        
        init(name: String = String(), exercises: [Exercise] = []) {
            self.id = .init()
            self.name = name
            self.exercises = exercises
        }
        
        var description: String {
            return "Training(id: \(id), name: \(name), exercises: \(exercises)"
        }
    }

    @Model
    final class Exercise: CustomStringConvertible {
        @Attribute(.unique)
        var id: UUID
        var name: String
        var serie: Serie
        
        init(name: String = String(), serie: Serie = .init()) {
            self.id = .init()
            self.name = name
            self.serie = serie
        }
        
        var description: String {
            return "Exercise(id: \(id), name: \(name), serie: \(serie)"
        }
    }

    
    @Model
    final class Serie: CustomStringConvertible {
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

enum WorkoutSchemaV1: VersionedSchema {
    static var versionIdentifier = Schema.Version(1, 0, 0)

    static var models: [any PersistentModel.Type] {
        return [Workout.self, Training.self, Exercise.self, Serie.self]
    }

    @Model
    final class Workout: CustomStringConvertible {
        var title: String
        var startDate: Date
        @Relationship(deleteRule: .cascade, inverse: \Training.workout)
        var trainings: [Training] = []
        
        init(title: String, startDate: Date, trainings: [Training]) {
            self.title = title
            self.startDate = startDate
            self.trainings = trainings
        }
        
        var description: String {
            return "Workout(title: \(title), startDate: \(startDate), trainings: \(trainings))"
        }
    }

    @Model
    final class Training: CustomStringConvertible {
        var name: String
        var exercises: [Exercise] = []
        
        @Relationship var workout: Workout?
        
        init(name: String = String(), exercises: [Exercise] = []) {
            self.name = name
            self.exercises = exercises
        }
        
        var description: String {
            return "Training(name: \(name), exercises: \(exercises))"
        }
    }

    @Model
    final class Exercise: CustomStringConvertible {
        var name: String
        var serie: Serie
        
        init(name: String = String(), serie: Serie = .init()) {
            self.name = name
            self.serie = serie
        }
        
        var description: String {
            return "Exercise(name: \(name), serie: \(serie))"
        }
    }

    @Model
    final class Serie: CustomStringConvertible {
        var quantity: Int?
        var minRep: Int?
        var maxRep: Int?
        
        init(quantity: Int? = nil, minRep: Int? = nil, maxRep: Int? = nil) {
            self.quantity = quantity
            self.minRep = minRep
            self.maxRep = maxRep
        }
        
        var description: String {
            return "Serie(quantity: \(String(describing: quantity)), minRep: \(String(describing: minRep)), maxRep: \(String(describing: maxRep)))"
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

