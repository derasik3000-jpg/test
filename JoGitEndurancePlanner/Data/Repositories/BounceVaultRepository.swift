import Foundation
import CoreData
import Combine

final class BounceVaultRepository: BounceVaultProtocol {
    private let coordinator: PersistenceCoordinator
    private let clockProvider: ClockProvider
    
    init(coordinator: PersistenceCoordinator = .shared, clockProvider: ClockProvider) {
        self.coordinator = coordinator
        self.clockProvider = clockProvider
    }
    
    private var context: NSManagedObjectContext {
        coordinator.context
    }
    
    func fetchActivePlan() -> AnyPublisher<TaperBlueprint?, Never> {
        Future { [weak self] promise in
            guard let self = self else {
                promise(.success(nil))
                return
            }
            
            let request: NSFetchRequest<DeloadRule> = DeloadRule.fetchRequest()
            request.sortDescriptors = [NSSortDescriptor(key: "updatedAt", ascending: false)]
            request.fetchLimit = 1
            
            do {
                let results = try self.context.fetch(request)
                if let entity = results.first {
                    let model = TaperBlueprint(
                        id: entity.id ?? UUID(),
                        reductionRate: Int(entity.percent),
                        cutbackStyle: CutbackStyle(rawValue: Int(entity.mode)) ?? .volume,
                        label: entity.title
                    )
                    promise(.success(model))
                } else {
                    promise(.success(nil))
                }
            } catch {
                promise(.success(nil))
            }
        }.eraseToAnyPublisher()
    }
    
    func storePlan(_ plan: TaperBlueprint) -> AnyPublisher<TaperBlueprint, Error> {
        Future { [weak self] promise in
            guard let self = self else {
                promise(.failure(NSError(domain: "BounceVault", code: -1)))
                return
            }
            
            let request: NSFetchRequest<DeloadRule> = DeloadRule.fetchRequest()
            request.predicate = NSPredicate(format: "id == %@", plan.id as CVarArg)
            
            do {
                let results = try self.context.fetch(request)
                let entity: DeloadRule
                
                if let existing = results.first {
                    entity = existing
                    entity.percent = Int16(plan.reductionRate)
                    entity.mode = Int16(plan.cutbackStyle.rawValue)
                    entity.title = plan.label
                    entity.updatedAt = self.clockProvider.currentMoment
                } else {
                    entity = DeloadRule(context: self.context)
                    entity.id = plan.id
                    entity.percent = Int16(plan.reductionRate)
                    entity.mode = Int16(plan.cutbackStyle.rawValue)
                    entity.title = plan.label
                    entity.createdAt = self.clockProvider.currentMoment
                    entity.updatedAt = self.clockProvider.currentMoment
                }
                
                try self.coordinator.saveContext()
                promise(.success(plan))
            } catch {
                promise(.failure(error))
            }
        }.eraseToAnyPublisher()
    }
    
    func anchorForCycle(at date: Date) -> Date {
        let calendar = Calendar.current
        var components = calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: date)
        components.weekday = 2
        return calendar.date(from: components) ?? date
    }
    
    func retrieveOrBuildCycle(kickoff: Date, blueprint: TaperBlueprint) -> AnyPublisher<SpanCycleModel, Error> {
        Future { [weak self] promise in
            guard let self = self else {
                promise(.failure(NSError(domain: "BounceVault", code: -1)))
                return
            }
            
            let request: NSFetchRequest<DeloadWeek> = DeloadWeek.fetchRequest()
            request.predicate = NSPredicate(format: "weekStart == %@", kickoff as NSDate)
            
            do {
                let results = try self.context.fetch(request)
                
                if let entity = results.first {
                    let workoutsRequest: NSFetchRequest<DeloadSession> = DeloadSession.fetchRequest()
                    workoutsRequest.predicate = NSPredicate(format: "week == %@", entity)
                    workoutsRequest.sortDescriptors = [NSSortDescriptor(key: "dayIndex", ascending: true)]
                    
                    let workoutEntities = try self.context.fetch(workoutsRequest)
                    let workouts = workoutEntities.map { self.mapToWorkoutModel($0) }
                    
                    let model = SpanCycleModel(
                        id: entity.id ?? UUID(),
                        kickoff: entity.weekStart ?? Date(),
                        closure: entity.weekEnd ?? Date(),
                        blueprint: TaperBlueprint(
                            id: blueprint.id,
                            reductionRate: Int(entity.targetPercent),
                            cutbackStyle: CutbackStyle(rawValue: Int(entity.mode)) ?? .volume
                        ),
                        workouts: workouts
                    )
                    promise(.success(model))
                } else {
                    let ruleRequest: NSFetchRequest<DeloadRule> = DeloadRule.fetchRequest()
                    ruleRequest.predicate = NSPredicate(format: "id == %@", blueprint.id as CVarArg)
                    var ruleEntity: DeloadRule
                    
                    if let existingRule = try self.context.fetch(ruleRequest).first {
                        ruleEntity = existingRule
                    } else {
                        ruleEntity = DeloadRule(context: self.context)
                        ruleEntity.id = blueprint.id
                        ruleEntity.percent = Int16(blueprint.reductionRate)
                        ruleEntity.mode = Int16(blueprint.cutbackStyle.rawValue)
                        ruleEntity.title = blueprint.label
                        ruleEntity.createdAt = self.clockProvider.currentMoment
                        ruleEntity.updatedAt = self.clockProvider.currentMoment
                    }
                    
                    let newEntity = DeloadWeek(context: self.context)
                    newEntity.id = UUID()
                    newEntity.weekStart = kickoff
                    newEntity.weekEnd = Calendar.current.date(byAdding: .day, value: 7, to: kickoff) ?? kickoff
                    newEntity.targetPercent = Int16(blueprint.reductionRate)
                    newEntity.mode = Int16(blueprint.cutbackStyle.rawValue)
                    newEntity.status = 0
                    newEntity.createdAt = self.clockProvider.currentMoment
                    newEntity.updatedAt = self.clockProvider.currentMoment
                    newEntity.rule = ruleEntity
                    
                    try self.coordinator.saveContext()
                    
                    let model = SpanCycleModel(
                        id: newEntity.id ?? UUID(),
                        kickoff: newEntity.weekStart ?? Date(),
                        closure: newEntity.weekEnd ?? Date(),
                        blueprint: blueprint,
                        workouts: []
                    )
                    promise(.success(model))
                }
            } catch {
                promise(.failure(error))
            }
        }.eraseToAnyPublisher()
    }
    
    func finalizeCycle(_ cycleId: UUID, digest: CycleDigest?) -> AnyPublisher<Void, Error> {
        Future { [weak self] promise in
            guard let self = self else {
                promise(.failure(NSError(domain: "BounceVault", code: -1)))
                return
            }
            
            let request: NSFetchRequest<DeloadWeek> = DeloadWeek.fetchRequest()
            request.predicate = NSPredicate(format: "id == %@", cycleId as CVarArg)
            
            do {
                let results = try self.context.fetch(request)
                if let entity = results.first {
                    entity.status = 1
                    entity.updatedAt = self.clockProvider.currentMoment
                    try self.coordinator.saveContext()
                }
                promise(.success(()))
            } catch {
                promise(.failure(error))
            }
        }.eraseToAnyPublisher()
    }
    
    func fetchWorkouts(cycleKickoff: Date) -> AnyPublisher<[WorkoutEntryModel], Error> {
        Future { [weak self] promise in
            guard let self = self else {
                promise(.failure(NSError(domain: "BounceVault", code: -1)))
                return
            }
            
            let weekRequest: NSFetchRequest<DeloadWeek> = DeloadWeek.fetchRequest()
            weekRequest.predicate = NSPredicate(format: "weekStart == %@", cycleKickoff as NSDate)
            
            do {
                let weekResults = try self.context.fetch(weekRequest)
                guard let week = weekResults.first else {
                    promise(.success([]))
                    return
                }
                
                let request: NSFetchRequest<DeloadSession> = DeloadSession.fetchRequest()
                request.predicate = NSPredicate(format: "week == %@", week)
                request.sortDescriptors = [NSSortDescriptor(key: "dayIndex", ascending: true)]
                
                let results = try self.context.fetch(request)
                let models = results.map { self.mapToWorkoutModel($0) }
                print("Fetched \(models.count) workouts")
                promise(.success(models))
            } catch {
                print("Error fetching workouts: \(error.localizedDescription)")
                promise(.failure(error))
            }
        }
        .receive(on: DispatchQueue.main)
        .eraseToAnyPublisher()
    }
    
    func insertWorkout(_ workout: WorkoutEntryModel, cycleKickoff: Date) -> AnyPublisher<WorkoutEntryModel, Error> {
        Future { [weak self] promise in
            guard let self = self else {
                promise(.failure(NSError(domain: "BounceVault", code: -1)))
                return
            }
            
            print("InsertWorkout called: \(workout.heading), kickoff: \(cycleKickoff)")
            
            let weekRequest: NSFetchRequest<DeloadWeek> = DeloadWeek.fetchRequest()
            weekRequest.predicate = NSPredicate(format: "weekStart == %@", cycleKickoff as NSDate)
            
            do {
                let weekResults = try self.context.fetch(weekRequest)
                print("Found \(weekResults.count) weeks for kickoff")
                guard let week = weekResults.first else {
                    print("Error: Week not found for kickoff \(cycleKickoff)")
                    promise(.failure(NSError(domain: "BounceVault", code: -2, userInfo: [NSLocalizedDescriptionKey: "Week not found"])))
                    return
                }
                
                let entity = DeloadSession(context: self.context)
                entity.id = workout.id
                entity.dayIndex = Int16(workout.slotIndex)
                entity.title = workout.heading
                entity.planMinutes = Int16(workout.scheduledDuration)
                entity.reducedMinutes = Int16(workout.adjustedDuration)
                entity.intensityLabel = workout.effortMarker
                entity.intensityReducedLabel = workout.easedEffortMarker
                entity.intervalReps = workout.repeatsCount.map { Int16($0) } ?? 0
                entity.intervalRepsReduced = workout.easedRepeatsCount.map { Int16($0) } ?? 0
                entity.isDone = workout.markedComplete
                entity.note = workout.memo
                entity.createdAt = self.clockProvider.currentMoment
                entity.updatedAt = self.clockProvider.currentMoment
                entity.week = week
                
                print("Saving context...")
                try self.coordinator.saveContext()
                print("Context saved successfully")
                
                promise(.success(workout))
            } catch {
                print("Error in insertWorkout: \(error.localizedDescription)")
                promise(.failure(error))
            }
        }
        .receive(on: DispatchQueue.main)
        .eraseToAnyPublisher()
    }
    
    func modifyWorkout(_ workout: WorkoutEntryModel) -> AnyPublisher<WorkoutEntryModel, Error> {
        Future { [weak self] promise in
            guard let self = self else {
                promise(.failure(NSError(domain: "BounceVault", code: -1)))
                return
            }
            
            let request: NSFetchRequest<DeloadSession> = DeloadSession.fetchRequest()
            request.predicate = NSPredicate(format: "id == %@", workout.id as CVarArg)
            
            do {
                let results = try self.context.fetch(request)
                guard let entity = results.first else {
                    promise(.failure(NSError(domain: "BounceVault", code: -3)))
                    return
                }
                
                entity.dayIndex = Int16(workout.slotIndex)
                entity.title = workout.heading
                entity.planMinutes = Int16(workout.scheduledDuration)
                entity.reducedMinutes = Int16(workout.adjustedDuration)
                entity.intensityLabel = workout.effortMarker
                entity.intensityReducedLabel = workout.easedEffortMarker
                entity.intervalReps = workout.repeatsCount.map { Int16($0) } ?? 0
                entity.intervalRepsReduced = workout.easedRepeatsCount.map { Int16($0) } ?? 0
                entity.isDone = workout.markedComplete
                entity.note = workout.memo
                entity.updatedAt = self.clockProvider.currentMoment
                
                try self.coordinator.saveContext()
                promise(.success(workout))
            } catch {
                promise(.failure(error))
            }
        }.eraseToAnyPublisher()
    }
    
    func eraseWorkout(_ id: UUID) -> AnyPublisher<Void, Error> {
        Future { [weak self] promise in
            guard let self = self else {
                promise(.failure(NSError(domain: "BounceVault", code: -1)))
                return
            }
            
            let request: NSFetchRequest<DeloadSession> = DeloadSession.fetchRequest()
            request.predicate = NSPredicate(format: "id == %@", id as CVarArg)
            
            do {
                let results = try self.context.fetch(request)
                if let entity = results.first {
                    self.context.delete(entity)
                    try self.coordinator.saveContext()
                }
                promise(.success(()))
            } catch {
                promise(.failure(error))
            }
        }.eraseToAnyPublisher()
    }
    
    func flipCompletion(_ id: UUID) -> AnyPublisher<WorkoutEntryModel, Error> {
        Future { [weak self] promise in
            guard let self = self else {
                promise(.failure(NSError(domain: "BounceVault", code: -1)))
                return
            }
            
            let request: NSFetchRequest<DeloadSession> = DeloadSession.fetchRequest()
            request.predicate = NSPredicate(format: "id == %@", id as CVarArg)
            
            do {
                let results = try self.context.fetch(request)
                guard let entity = results.first else {
                    promise(.failure(NSError(domain: "BounceVault", code: -3)))
                    return
                }
                
                entity.isDone.toggle()
                entity.updatedAt = self.clockProvider.currentMoment
                
                try self.coordinator.saveContext()
                
                let model = self.mapToWorkoutModel(entity)
                promise(.success(model))
            } catch {
                promise(.failure(error))
            }
        }.eraseToAnyPublisher()
    }
    
    func recomputeBlueprint(cycleKickoff: Date, blueprint: TaperBlueprint) -> AnyPublisher<[WorkoutEntryModel], Error> {
        Future { [weak self] promise in
            guard let self = self else {
                promise(.failure(NSError(domain: "BounceVault", code: -1)))
                return
            }
            
            let weekRequest: NSFetchRequest<DeloadWeek> = DeloadWeek.fetchRequest()
            weekRequest.predicate = NSPredicate(format: "weekStart == %@", cycleKickoff as NSDate)
            
            do {
                let weekResults = try self.context.fetch(weekRequest)
                guard let week = weekResults.first else {
                    promise(.failure(NSError(domain: "BounceVault", code: -2)))
                    return
                }
                
                week.targetPercent = Int16(blueprint.reductionRate)
                week.mode = Int16(blueprint.cutbackStyle.rawValue)
                week.updatedAt = self.clockProvider.currentMoment
                
                let request: NSFetchRequest<DeloadSession> = DeloadSession.fetchRequest()
                request.predicate = NSPredicate(format: "week == %@", week)
                
                let sessions = try self.context.fetch(request)
                var updatedModels: [WorkoutEntryModel] = []
                
                for session in sessions {
                    let originalPlan = Int(session.planMinutes)
                    let reduction = self.computeReduction(
                        planMinutes: originalPlan,
                        reductionRate: blueprint.reductionRate,
                        style: blueprint.cutbackStyle,
                        intensityLabel: session.intensityLabel,
                        intervalReps: session.intervalReps > 0 ? Int(session.intervalReps) : nil
                    )
                    
                    session.reducedMinutes = Int16(reduction.adjustedDuration)
                    session.intensityReducedLabel = reduction.easedEffortMarker
                    if let reps = reduction.easedRepeatsCount {
                        session.intervalRepsReduced = Int16(reps)
                    }
                    session.updatedAt = self.clockProvider.currentMoment
                    
                    updatedModels.append(self.mapToWorkoutModel(session))
                }
                
                try self.coordinator.saveContext()
                promise(.success(updatedModels))
            } catch {
                promise(.failure(error))
            }
        }.eraseToAnyPublisher()
    }
    
    private func mapToWorkoutModel(_ entity: DeloadSession) -> WorkoutEntryModel {
        WorkoutEntryModel(
            id: entity.id ?? UUID(),
            slotIndex: Int(entity.dayIndex),
            heading: entity.title ?? "",
            scheduledDuration: Int(entity.planMinutes),
            adjustedDuration: Int(entity.reducedMinutes),
            effortMarker: entity.intensityLabel,
            easedEffortMarker: entity.intensityReducedLabel,
            repeatsCount: entity.intervalReps > 0 ? Int(entity.intervalReps) : nil,
            easedRepeatsCount: entity.intervalRepsReduced > 0 ? Int(entity.intervalRepsReduced) : nil,
            markedComplete: entity.isDone,
            memo: entity.note
        )
    }
    
    private func computeReduction(planMinutes: Int, reductionRate: Int, style: CutbackStyle, intensityLabel: String?, intervalReps: Int?) -> (adjustedDuration: Int, easedEffortMarker: String?, easedRepeatsCount: Int?) {
        let rate = Double(reductionRate) / 100.0
        var adjustedMinutes = planMinutes
        var easedLabel = intensityLabel
        var easedReps = intervalReps
        
        switch style {
        case .volume:
            adjustedMinutes = max(10, Int(round(Double(planMinutes) * (1.0 - rate))))
            
        case .intensity:
            if let label = intensityLabel {
                easedLabel = easeIntensity(label, rate: reductionRate)
            }
            if let reps = intervalReps {
                easedReps = max(1, Int(ceil(Double(reps) * (1.0 - rate))))
            }
            
        case .both:
            adjustedMinutes = max(10, Int(round(Double(planMinutes) * (1.0 - rate))))
            if let label = intensityLabel {
                easedLabel = easeIntensity(label, rate: reductionRate)
            }
            if let reps = intervalReps {
                easedReps = max(1, Int(ceil(Double(reps) * (1.0 - rate))))
            }
        }
        
        return (adjustedMinutes, easedLabel, easedReps)
    }
    
    private func easeIntensity(_ label: String, rate: Int) -> String {
        let lower = label.lowercased()
        if lower.contains("tempo") || lower.contains("pace") {
            return "Easier"
        } else if lower.contains("interval") {
            return "Fewer Reps"
        } else if lower.contains("hills") || lower.contains("strength") {
            return "Lighter"
        } else if lower.contains("easy") || lower.contains("z2") {
            return label
        } else {
            return "Lighter"
        }
    }
}

