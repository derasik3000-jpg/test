import Foundation
import CoreData

class CoreDataEtherealMilestoneRepository: EtherealMilestoneRepository {
    private let context: NSManagedObjectContext
    
    init(context: NSManagedObjectContext) {
        self.context = context
    }
    
    func loadMilestonesCatalog(for sphereId: UUID) async throws -> [EtherealMilestone] {
        try await context.perform {
            let request = AchievementRecord.fetchRequest()
            request.predicate = NSPredicate(format: "cosmicSphereAnchor.zephyrId == %@", sphereId as CVarArg)
            request.sortDescriptors = [NSSortDescriptor(keyPath: \AchievementRecord.temporalAchievementDate, ascending: false)]
            
            let entities = try self.context.fetch(request)
            return entities.compactMap { self.mapAchievementRecordToDomainMilestone($0) }
        }
    }
    
    func insertMilestoneRecord(sphereId: UUID, title: String, note: String?, date: Date, linkedEntryId: UUID?) async throws -> EtherealMilestone {
        try await context.perform {
            let sphereRequest = CategoryRecord.fetchRequest()
            sphereRequest.predicate = NSPredicate(format: "zephyrId == %@", sphereId as CVarArg)
            guard let sphere = try self.context.fetch(sphereRequest).first else {
                throw AuroraFluxError.notFound
            }
            
            let entity = AchievementRecord(context: self.context)
            entity.zephyrId = UUID()
            entity.epicTitleText = title
            entity.chronicleNoteContent = note
            entity.temporalAchievementDate = date
            entity.connectedEntryReference = linkedEntryId
            entity.cosmicSphereAnchor = sphere
            
            try self.context.save()
            return self.mapAchievementRecordToDomainMilestone(entity)!
        }
    }
    
    func updateMilestoneRecord(id: UUID, title: String?, note: String?, date: Date?, linkedEntryId: UUID?) async throws -> EtherealMilestone {
        try await context.perform {
            let request = AchievementRecord.fetchRequest()
            request.predicate = NSPredicate(format: "zephyrId == %@", id as CVarArg)
            
            guard let entity = try self.context.fetch(request).first else {
                throw AuroraFluxError.notFound
            }
            
            if let title = title {
                entity.epicTitleText = title
            }
            if let note = note {
                entity.chronicleNoteContent = note
            }
            if let date = date {
                entity.temporalAchievementDate = date
            }
            if let linkedEntryId = linkedEntryId {
                entity.connectedEntryReference = linkedEntryId
            }
            
            try self.context.save()
            return self.mapAchievementRecordToDomainMilestone(entity)!
        }
    }
    
    func removeMilestoneById(id: UUID) async throws {
        try await context.perform {
            let request = AchievementRecord.fetchRequest()
            request.predicate = NSPredicate(format: "zephyrId == %@", id as CVarArg)
            
            guard let entity = try self.context.fetch(request).first else {
                throw AuroraFluxError.notFound
            }
            
            self.context.delete(entity)
            try self.context.save()
        }
    }
    
    private func mapAchievementRecordToDomainMilestone(_ entity: AchievementRecord) -> EtherealMilestone? {
        guard let id = entity.zephyrId,
              let sphereId = entity.cosmicSphereAnchor?.zephyrId,
              let title = entity.epicTitleText,
              let date = entity.temporalAchievementDate else {
            return nil
        }
        
        return EtherealMilestone(
            id: id,
            sphereId: sphereId,
            epicTitleText: title,
            chronicleNoteContent: entity.chronicleNoteContent,
            temporalAchievementDate: date,
            connectedEntryReference: entity.connectedEntryReference
        )
    }
}

