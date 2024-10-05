import Foundation
import CoreData

extension WorkoutEntity: Identifiable {}
extension ExerciseEntity: Identifiable {}
extension TagEntity: Identifiable {}

enum FeatureType {
    case exercise
    case tag
    case none
    
    var name: String {
        switch self {
        case .exercise:
            return "Exercícios"
        case .tag:
            return "Tags"
        case .none:
            return ""
        }
    }
}

struct Exercise: Convertable, Selectable, Equatable, Identifiable, Hashable {
    let name: String
    let tags: [Tag]
    let workouts: [Workout]
    let id: UUID

    init(
        name: String,
        tags: [Tag] = [],
        workouts: [Workout] = [],
        id: UUID = .init()
    ) {
        self.name = name
        self.tags = tags
        self.workouts = workouts
        self.id = id
    }

    init(from entity: ExerciseEntity) {
        self.name = entity.name
        self.tags = []
        self.workouts = []
        self.id = entity.id ?? UUID()
    }
    
    static func make(from entity: NSManagedObject) -> Convertable? {
        guard let entity = entity as? ExerciseEntity else {
            return nil
        }
        return Self(from: entity)
    }
    
    func toEntity(with context: NSManagedObjectContext) -> NSManagedObject {
        return toExercise(with: context)
    }
    
    func toExercise(with context: NSManagedObjectContext) -> ExerciseEntity {
        let entity = ExerciseEntity(context: context)
        entity.name = name
        entity.id = id
        let selectedWorkouts: [WorkoutEntity] = workouts.map {
            let workout = WorkoutEntity(context: context)
            workout.id = $0.id
            workout.name = $0.name
            return workout
        }
        selectedWorkouts.forEach {
            entity.addToWorkouts($0)
        }

        let selectedTags: [TagEntity] = tags.map {
            let tag = TagEntity(context: context)
            tag.id = $0.id
            tag.name = $0.name
            return tag
        }
        selectedTags.forEach {
            entity.addToTags($0)
        }
        return entity
    }
}
struct Tag: Convertable, Selectable, Equatable, Identifiable, Hashable {
    let name: String
    let workouts: [Workout]
    let exercises: [Exercise]
    let id: UUID
    
    init(
        name: String,
        workouts: [Workout] = [],
        exercises: [Exercise] = [],
        id: UUID = .init()
    ) {
        self.name = name
        self.workouts = workouts
        self.exercises = exercises
        self.id = id
    }
    
    init(from entity: TagEntity) {
        self.name = entity.name
        self.workouts = []
        self.exercises = []
        self.id = entity.id ?? UUID()
    }
    
    static func make(from entity: NSManagedObject) -> Convertable? {
        guard let entity = entity as? TagEntity else {
            return nil
        }
        return Self(from: entity)
    }
    
    func toEntity(with context: NSManagedObjectContext) -> NSManagedObject {
        toTag(with: context)
    }
    
    func toTag(with context: NSManagedObjectContext) -> TagEntity {
        let entity = TagEntity(context: context)
        entity.name = name
        entity.id = id
        let selectedWorkouts: [WorkoutEntity] = workouts.map {
            let workout = WorkoutEntity(context: context)
            workout.id = $0.id
            workout.name = $0.name
            return workout
        }
        let selectedExercises: [ExerciseEntity] = exercises.map {
            let exercise = ExerciseEntity(context: context)
            exercise.id = $0.id
            exercise.name = $0.name
            return exercise
        }
        selectedWorkouts.forEach {
            entity.addToWorkouts($0)
        }
        selectedExercises.forEach {
            entity.addToExercises($0)
        }
        return entity
    }
}

struct Workout: Convertable, Equatable, Identifiable, Hashable {
    let name: String
    let tags: [Tag]
    let exercises: [Exercise]
    let id: UUID

    init(
        name: String,
        tags: [Tag],
        exercises: [Exercise],
        id: UUID = .init()
    ) {
        self.name = name
        self.tags = tags
        self.exercises = exercises
        self.id = id
    }

    init(from entity: WorkoutEntity) {
        self.name = entity.name
        let tags = entity.tags
        let convertedTags = tags?
            .compactMap({ tag in
                Tag(from: tag)
            })
        self.tags = convertedTags ?? []
        let exercises = entity.exercises
        let convertedExercises = exercises?
            .compactMap({ exercise in
                Exercise(from: exercise)
            })
        
        self.exercises = convertedExercises ?? []
        self.id = entity.id ?? UUID()
    }
    
    static func make(from entity: NSManagedObject) -> Convertable? {
        guard let entity = entity as? WorkoutEntity else {
            return nil
        }
        return Self(from: entity)
    }
    
    func toEntity(with context: NSManagedObjectContext) -> NSManagedObject {
        toWorkout(with: context)
    }
    
    func toWorkout(with context: NSManagedObjectContext) -> WorkoutEntity {
        let entity = WorkoutEntity(context: context)
        entity.name = name
        let selectedTags: [TagEntity] = tags.map {
            let tag = TagEntity(context: context)
            tag.id = $0.id
            tag.name = $0.name
            return tag
        }
        selectedTags.forEach {
            entity.addToTags($0)
        }

        let selectedExercises: [ExerciseEntity] = exercises.map {
            let exercise = ExerciseEntity(context: context)
            exercise.id = $0.id
            exercise.name = $0.name
            return exercise
        }
        selectedExercises.forEach {
            entity.addToExercises($0)
        }
        return entity
    }
}

extension Workout {
    static let mock = Self.init(name: "teste", tags: [], exercises: [], id: UUID())
}


protocol Convertable {
    static func make(from entity: NSManagedObject) -> Convertable?
    func toEntity(with context: NSManagedObjectContext) -> NSManagedObject
}


//
//import Foundation
//import CoreData
//
//extension WorkoutEntity: Identifiable {}
//extension ExerciseEntity: Identifiable {}
//extension TagEntity: Identifiable {}
//
//struct Exercise: Convertable, Equatable, Identifiable, Hashable {
//    let name: String
//    let tags: [TagIdentity]
//    let workouts: [WorkoutIdentity]
//    let id: UUID
//
//    init(
//        name: String,
//        tags: [TagIdentity] = [],
//        workouts: [WorkoutIdentity] = [],
//        id: UUID = .init()
//    ) {
//        self.name = name
//        self.tags = tags
//        self.workouts = workouts
//        self.id = id
//    }
//
//    init(from entity: ExerciseEntity) {
//        self.name = entity.name
//        let tags = entity.tags
//        let convertedTags = tags?
//            .compactMap({ tag in
//                TagIdentity(from: tag)
//            })
//        self.tags = convertedTags ?? []
//        let workouts = entity.workouts
//        let convertedObjs = workouts?.compactMap({ workout in
//            WorkoutIdentity(from: workout)
//        })
//        self.workouts = convertedObjs ?? []
//        self.id = entity.id ?? UUID()
//    }
//
//    static func make(from entity: NSManagedObject) -> Convertable? {
//        guard let entity = entity as? ExerciseEntity else {
//            return nil
//        }
//        return Self(from: entity)
//    }
//
//    func toEntity(with context: NSManagedObjectContext) -> NSManagedObject {
//        return toExercise(with: context)
//    }
//
//    func toExercise(with context: NSManagedObjectContext) -> ExerciseEntity {
//        let entity = ExerciseEntity(context: context)
//        entity.name = name
//        let selectedWorkouts: [WorkoutEntity] = workouts.map {
//            let workout = WorkoutEntity(context: context)
//            workout.id = $0.id
//            workout.name = $0.name
//            return workout
//        }
//        selectedWorkouts.forEach {
//            entity.addToWorkouts($0)
//        }
//
//        let selectedTags: [TagEntity] = tags.map {
//            let tag = TagEntity(context: context)
//            tag.id = $0.id
//            tag.name = $0.name
//            tag.type = $0.type
//            return tag
//        }
//        selectedTags.forEach {
//            entity.addToTags($0)
//        }
//        return entity
//    }
//}
//
//
//struct ExerciseIdentity:  Equatable, Identifiable, Hashable {
//    let name: String
//    let id: UUID
//
//    init(
//        name: String,
//        id: UUID = .init()
//    ) {
//        self.name = name
//        self.id = id
//    }
//
//    init(from entity: ExerciseEntity) {
//        self.name = entity.name
//        self.id = entity.id ?? UUID()
//    }
//}
//
//struct Tag: Convertable, Equatable, Identifiable, Hashable {
//    let name: String
//    let type: String
//    let workouts: [WorkoutIdentity]
//    let exercises: [ExerciseIdentity]
//    let id: UUID
//
//    init(
//        name: String,
//        type: String,
//        workouts: [WorkoutIdentity] = [],
//        exercises: [ExerciseIdentity] = [],
//        id: UUID = .init()
//    ) {
//        self.name = name
//        self.type = type
//        self.workouts = workouts
//        self.exercises = exercises
//        self.id = id
//    }
//
//    init(from entity: TagEntity) {
//        self.name = entity.name
//        self.type = entity.type
//        let workouts = entity.workouts
//        let convertedWorkouts = workouts?
//            .compactMap({ workout in
//                WorkoutIdentity(from: workout)
//            })
//        self.workouts = convertedWorkouts ?? []
//        let exercises = entity.exercises
//        let convertedExercises = exercises?
//            .compactMap({ exercise in
//                ExerciseIdentity(from: exercise)
//            })
//        self.exercises = convertedExercises ?? []
//        self.id = entity.id ?? UUID()
//    }
//
//    static func make(from entity: NSManagedObject) -> Convertable? {
//        guard let entity = entity as? TagEntity else {
//            return nil
//        }
//        return Self(from: entity)
//    }
//
//    func toEntity(with context: NSManagedObjectContext) -> NSManagedObject {
//        toTag(with: context)
//    }
//
//    func toTag(with context: NSManagedObjectContext) -> TagEntity {
//        let entity = TagEntity(context: context)
//        entity.name = name
//        entity.type = type
//        let selectedWorkouts: [WorkoutEntity] = workouts.map {
//            let workout = WorkoutEntity(context: context)
//            workout.id = $0.id
//            workout.name = $0.name
//            return workout
//        }
//        let selectedExercises: [ExerciseEntity] = exercises.map {
//            let exercise = ExerciseEntity(context: context)
//            exercise.id = $0.id
//            exercise.name = $0.name
//            return exercise
//        }
//        selectedWorkouts.forEach {
//            entity.addToWorkouts($0)
//        }
//        selectedExercises.forEach {
//            entity.addToExercises($0)
//        }
//        return entity
//    }
//}
//
//struct TagIdentity: Equatable, Identifiable, Hashable {
//    let name: String
//    let type: String
//    let id: UUID
//
//    init(
//        name: String,
//        type: String,
//        id: UUID = .init()
//    ) {
//        self.name = name
//        self.type = type
//        self.id = id
//    }
//
//    init(from entity: TagEntity) {
//        self.name = entity.name
//        self.type = entity.type
//        self.id = entity.id ?? UUID()
//    }
//}
//
//struct Workout: Convertable, Equatable, Identifiable, Hashable {
//    let name: String
//    let tags: [TagIdentity]
//    let exercises: [ExerciseIdentity]
//    let id: UUID
//
//    init(
//        name: String,
//        tags: [TagIdentity],
//        exercises: [ExerciseIdentity],
//        id: UUID = .init()
//    ) {
//        self.name = name
//        self.tags = tags
//        self.exercises = exercises
//        self.id = id
//    }
//
//    init(from entity: WorkoutEntity) {
//        self.name = entity.name
//        let tags = entity.tags
//        let convertedTags = tags?
//            .compactMap({ tag in
//                TagIdentity(from: tag)
//            })
//        self.tags = convertedTags ?? []
//        let exercises = entity.exercises
//        let convertedExercises = exercises?
//            .compactMap({ exercise in
//                ExerciseIdentity(from: exercise)
//            })
//
//        self.exercises = convertedExercises ?? []
//        self.id = entity.id ?? UUID()
//    }
//
//    static func make(from entity: NSManagedObject) -> Convertable? {
//        guard let entity = entity as? WorkoutEntity else {
//            return nil
//        }
//        return Self(from: entity)
//    }
//
//    func toEntity(with context: NSManagedObjectContext) -> NSManagedObject {
//        toWorkout(with: context)
//    }
//
//    func toWorkout(with context: NSManagedObjectContext) -> WorkoutEntity {
//        let entity = WorkoutEntity(context: context)
//        entity.name = name
//        let selectedTags: [TagEntity] = tags.map {
//            let tag = TagEntity(context: context)
//            tag.id = $0.id
//            tag.name = $0.name
//            tag.type = $0.type
//            return tag
//        }
//        selectedTags.forEach {
//            entity.addToTags($0)
//        }
//
//        let selectedExercises: [ExerciseEntity] = exercises.map {
//            let exercise = ExerciseEntity(context: context)
//            exercise.id = $0.id
//            exercise.name = $0.name
//            return exercise
//        }
//        selectedExercises.forEach {
//            entity.addToExercises($0)
//        }
//        return entity
//    }
//}
//
//
//struct WorkoutIdentity: Equatable, Identifiable, Hashable {
//    let name: String
//    let id: UUID
//
//    init(
//        name: String,
//        id: UUID = .init()
//    ) {
//        self.name = name
//        self.id = id
//    }
//
//    init(from entity: WorkoutEntity) {
//        self.name = entity.name
//        self.id = entity.id ?? UUID()
//    }
//}
//
//extension Workout {
//    static let mock = Self.init(name: "teste", tags: [], exercises: [], id: UUID())
//}
//
//
//protocol Convertable {
//    static func make(from entity: NSManagedObject) -> Convertable?
//    func toEntity(with context: NSManagedObjectContext) -> NSManagedObject
//}
