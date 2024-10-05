// swiftlint:disable all
// Generated using SwiftGen — https://github.com/SwiftGen/SwiftGen

// swiftlint:disable superfluous_disable_command implicit_return
// swiftlint:disable sorted_imports
import CoreData
import Foundation

// swiftlint:disable attributes file_length vertical_whitespace_closing_braces
// swiftlint:disable identifier_name line_length type_body_length

// MARK: - ExerciseEntity

internal class ExerciseEntity: NSManagedObject {
  internal class var entityName: String {
    return "ExerciseEntity"
  }

  internal class func entity(in managedObjectContext: NSManagedObjectContext) -> NSEntityDescription? {
    return NSEntityDescription.entity(forEntityName: entityName, in: managedObjectContext)
  }

  @available(*, deprecated, renamed: "makeFetchRequest", message: "To avoid collisions with the less concrete method in `NSManagedObject`, please use `makeFetchRequest()` instead.")
  @nonobjc internal class func fetchRequest() -> NSFetchRequest<ExerciseEntity> {
    return NSFetchRequest<ExerciseEntity>(entityName: entityName)
  }

  @nonobjc internal class func makeFetchRequest() -> NSFetchRequest<ExerciseEntity> {
    return NSFetchRequest<ExerciseEntity>(entityName: entityName)
  }

  // swiftlint:disable discouraged_optional_boolean discouraged_optional_collection
  @NSManaged internal var id: UUID?
  @NSManaged internal var name: String
  @NSManaged internal var tags: Set<TagEntity>?
  @NSManaged internal var workouts: Set<WorkoutEntity>?
  // swiftlint:enable discouraged_optional_boolean discouraged_optional_collection
}

// MARK: Relationship Tags

extension ExerciseEntity {
  @objc(addTagsObject:)
  @NSManaged public func addToTags(_ value: TagEntity)

  @objc(removeTagsObject:)
  @NSManaged public func removeFromTags(_ value: TagEntity)

  @objc(addTags:)
  @NSManaged public func addToTags(_ values: Set<TagEntity>)

  @objc(removeTags:)
  @NSManaged public func removeFromTags(_ values: Set<TagEntity>)
}

// MARK: Relationship Workouts

extension ExerciseEntity {
  @objc(addWorkoutsObject:)
  @NSManaged public func addToWorkouts(_ value: WorkoutEntity)

  @objc(removeWorkoutsObject:)
  @NSManaged public func removeFromWorkouts(_ value: WorkoutEntity)

  @objc(addWorkouts:)
  @NSManaged public func addToWorkouts(_ values: Set<WorkoutEntity>)

  @objc(removeWorkouts:)
  @NSManaged public func removeFromWorkouts(_ values: Set<WorkoutEntity>)
}

// MARK: - TagEntity

internal class TagEntity: NSManagedObject {
  internal class var entityName: String {
    return "TagEntity"
  }

  internal class func entity(in managedObjectContext: NSManagedObjectContext) -> NSEntityDescription? {
    return NSEntityDescription.entity(forEntityName: entityName, in: managedObjectContext)
  }

  @available(*, deprecated, renamed: "makeFetchRequest", message: "To avoid collisions with the less concrete method in `NSManagedObject`, please use `makeFetchRequest()` instead.")
  @nonobjc internal class func fetchRequest() -> NSFetchRequest<TagEntity> {
    return NSFetchRequest<TagEntity>(entityName: entityName)
  }

  @nonobjc internal class func makeFetchRequest() -> NSFetchRequest<TagEntity> {
    return NSFetchRequest<TagEntity>(entityName: entityName)
  }

  // swiftlint:disable discouraged_optional_boolean discouraged_optional_collection
  @NSManaged internal var id: UUID?
  @NSManaged internal var name: String
  @NSManaged internal var exercises: Set<ExerciseEntity>?
  @NSManaged internal var workouts: Set<WorkoutEntity>?
  // swiftlint:enable discouraged_optional_boolean discouraged_optional_collection
}

// MARK: Relationship Exercises

extension TagEntity {
  @objc(addExercisesObject:)
  @NSManaged public func addToExercises(_ value: ExerciseEntity)

  @objc(removeExercisesObject:)
  @NSManaged public func removeFromExercises(_ value: ExerciseEntity)

  @objc(addExercises:)
  @NSManaged public func addToExercises(_ values: Set<ExerciseEntity>)

  @objc(removeExercises:)
  @NSManaged public func removeFromExercises(_ values: Set<ExerciseEntity>)
}

// MARK: Relationship Workouts

extension TagEntity {
  @objc(addWorkoutsObject:)
  @NSManaged public func addToWorkouts(_ value: WorkoutEntity)

  @objc(removeWorkoutsObject:)
  @NSManaged public func removeFromWorkouts(_ value: WorkoutEntity)

  @objc(addWorkouts:)
  @NSManaged public func addToWorkouts(_ values: Set<WorkoutEntity>)

  @objc(removeWorkouts:)
  @NSManaged public func removeFromWorkouts(_ values: Set<WorkoutEntity>)
}

// MARK: - WorkoutEntity

internal class WorkoutEntity: NSManagedObject {
  internal class var entityName: String {
    return "WorkoutEntity"
  }

  internal class func entity(in managedObjectContext: NSManagedObjectContext) -> NSEntityDescription? {
    return NSEntityDescription.entity(forEntityName: entityName, in: managedObjectContext)
  }

  @available(*, deprecated, renamed: "makeFetchRequest", message: "To avoid collisions with the less concrete method in `NSManagedObject`, please use `makeFetchRequest()` instead.")
  @nonobjc internal class func fetchRequest() -> NSFetchRequest<WorkoutEntity> {
    return NSFetchRequest<WorkoutEntity>(entityName: entityName)
  }

  @nonobjc internal class func makeFetchRequest() -> NSFetchRequest<WorkoutEntity> {
    return NSFetchRequest<WorkoutEntity>(entityName: entityName)
  }

  // swiftlint:disable discouraged_optional_boolean discouraged_optional_collection
  @NSManaged internal var id: UUID?
  @NSManaged internal var name: String
  @NSManaged internal var exercises: Set<ExerciseEntity>?
  @NSManaged internal var tags: Set<TagEntity>?
  // swiftlint:enable discouraged_optional_boolean discouraged_optional_collection
}

// MARK: Relationship Exercises

extension WorkoutEntity {
  @objc(addExercisesObject:)
  @NSManaged public func addToExercises(_ value: ExerciseEntity)

  @objc(removeExercisesObject:)
  @NSManaged public func removeFromExercises(_ value: ExerciseEntity)

  @objc(addExercises:)
  @NSManaged public func addToExercises(_ values: Set<ExerciseEntity>)

  @objc(removeExercises:)
  @NSManaged public func removeFromExercises(_ values: Set<ExerciseEntity>)
}

// MARK: Relationship Tags

extension WorkoutEntity {
  @objc(addTagsObject:)
  @NSManaged public func addToTags(_ value: TagEntity)

  @objc(removeTagsObject:)
  @NSManaged public func removeFromTags(_ value: TagEntity)

  @objc(addTags:)
  @NSManaged public func addToTags(_ values: Set<TagEntity>)

  @objc(removeTags:)
  @NSManaged public func removeFromTags(_ values: Set<TagEntity>)
}

// swiftlint:enable identifier_name line_length type_body_length
