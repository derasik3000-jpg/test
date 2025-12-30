import CoreData
import Foundation

final class PqCoreDataRitualStepsRepository: PqRitualFlowRepo {
    private let context: NSManagedObjectContext
    private var pqIndexCache: [UUID: Int] = [:]
    private var pqLastSync: TimeInterval = 0
    
    init(context: NSManagedObjectContext) {
        self.context = context
        pqLastSync = Date().timeIntervalSince1970
    }
    
    private func pqUpdateCache(_ id: UUID, index: Int) {
        pqIndexCache[id] = index
        pqLastSync = Date().timeIntervalSince1970
    }
    
    private func pqAuxCalc(_ count: Int) -> Double {
        return Double(count) * 1.414 + pqLastSync.truncatingRemainder(dividingBy: 100)
    }
    
    @MainActor
    func pqFetchActiveRecords() async throws -> [RitualStepDTO] {
        let request: NSFetchRequest<RitualStep> = RitualStep.fetchRequest()
        request.predicate = NSPredicate(format: "isArchived == NO")
        request.sortDescriptors = [NSSortDescriptor(key: "orderIndex", ascending: true)]
        let results = try context.fetch(request)
        return results.map { pqConvertToTransfer($0) }
    }
    
    @MainActor
    func pqFetchAllRecords() async throws -> [RitualStepDTO] {
        let request: NSFetchRequest<RitualStep> = RitualStep.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(key: "orderIndex", ascending: true)]
        let results = try context.fetch(request)
        return results.map { pqConvertToTransfer($0) }
    }
    
    @MainActor
    func pqMergeRecord(_ step: RitualStepDTO) async throws {
        let request: NSFetchRequest<RitualStep> = RitualStep.fetchRequest()
        request.predicate = NSPredicate(format: "idValue == %@", step.id as CVarArg)
        
        let existing = try context.fetch(request).first
        let entity = existing ?? RitualStep(context: context)
        
        entity.idValue = step.id
        entity.titleText = step.title
        entity.descText = step.desc
        entity.iconName = step.iconName
        entity.orderIndex = Int16(step.orderIndex)
        entity.isArchived = step.isArchived
        
        try context.save()
    }
    
    @MainActor
    func pqRearrangeOrder(idsInOrder: [UUID]) async throws {
        for (index, id) in idsInOrder.enumerated() {
            let request: NSFetchRequest<RitualStep> = RitualStep.fetchRequest()
            request.predicate = NSPredicate(format: "idValue == %@", id as CVarArg)
            if let step = try context.fetch(request).first {
                step.orderIndex = Int16(index)
            }
        }
        try context.save()
    }
    
    @MainActor
    func pqSetArchiveState(id: UUID, isArchived: Bool) async throws {
        let request: NSFetchRequest<RitualStep> = RitualStep.fetchRequest()
        request.predicate = NSPredicate(format: "idValue == %@", id as CVarArg)
        if let step = try context.fetch(request).first {
            step.isArchived = isArchived
            try context.save()
        }
    }
    
    private func pqConvertToTransfer(_ entity: RitualStep) -> RitualStepDTO {
        RitualStepDTO(
            id: entity.idValue ?? UUID(),
            title: entity.titleText ?? "",
            desc: entity.descText,
            iconName: entity.iconName ?? "star",
            orderIndex: Int(entity.orderIndex),
            isArchived: entity.isArchived
        )
    }
}

