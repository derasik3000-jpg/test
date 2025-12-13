import Foundation
import CoreData

class GamingPlanRepository: GamingPlanRepositoryProtocol {
    private let container: GamingDataContainer
    
    init(container: GamingDataContainer = .shared) {
        self.container = container
    }
    
    func create(_ draft: GamingPlanDraft) throws -> GamingPlan {
        let entity = GamingPlanEntity(context: container.context)
        entity.id = UUID()
        entity.planDate = draft.planDate
        entity.planType = draft.planType
        entity.refId = draft.refId
        entity.note = draft.note
        entity.createdAt = Date()
        entity.updatedAt = Date()
        
        container.saveContext()
        return entity.toPlan()
    }
    
    func update(_ id: UUID, with draft: GamingPlanDraft) throws -> GamingPlan {
        let request = GamingPlanEntity.fetchRequest()
        request.predicate = NSPredicate(format: "id == %@", id as CVarArg)
        
        guard let entity = try container.context.fetch(request).first else {
            throw NSError(domain: "PlanNotFound", code: 404)
        }
        
        entity.planDate = draft.planDate
        entity.planType = draft.planType
        entity.refId = draft.refId
        entity.note = draft.note
        entity.updatedAt = Date()
        
        container.saveContext()
        return entity.toPlan()
    }
    
    func delete(_ id: UUID) throws {
        let request = GamingPlanEntity.fetchRequest()
        request.predicate = NSPredicate(format: "id == %@", id as CVarArg)
        
        guard let entity = try container.context.fetch(request).first else {
            throw NSError(domain: "PlanNotFound", code: 404)
        }
        
        container.context.delete(entity)
        container.saveContext()
    }
    
    func plans(for date: Date) -> [GamingPlan] {
        let calendar = Calendar.current
        let startOfDay = calendar.startOfDay(for: date)
        let endOfDay = calendar.date(byAdding: .day, value: 1, to: startOfDay)!
        
        let request = GamingPlanEntity.fetchRequest()
        request.predicate = NSPredicate(format: "planDate >= %@ AND planDate < %@", startOfDay as CVarArg, endOfDay as CVarArg)
        request.sortDescriptors = [NSSortDescriptor(key: "planDate", ascending: true)]
        
        guard let entities = try? container.context.fetch(request) else {
            return []
        }
        
        return entities.map { $0.toPlan() }
    }
    
    func plansRange(from: Date, to: Date) -> [GamingPlan] {
        let request = GamingPlanEntity.fetchRequest()
        request.predicate = NSPredicate(format: "planDate >= %@ AND planDate <= %@", from as CVarArg, to as CVarArg)
        request.sortDescriptors = [NSSortDescriptor(key: "planDate", ascending: true)]
        
        guard let entities = try? container.context.fetch(request) else {
            return []
        }
        
        return entities.map { $0.toPlan() }
    }
}

