import Foundation
import CoreData

class GamingRecordRepository: GamingRecordRepositoryProtocol {
    private let container: GamingDataContainer
    
    init(container: GamingDataContainer = .shared) {
        self.container = container
    }
    
    func create(_ draft: GamingRecordDraft) throws -> GamingRecord {
        let entity = GamingRecordEntity(context: container.context)
        entity.id = UUID()
        entity.text = draft.text
        entity.recordDate = draft.recordDate
        entity.imageData = draft.imageData
        entity.createdAt = Date()
        entity.updatedAt = Date()
        
        container.saveContext()
        return entity.toRecord()
    }
    
    func update(_ id: UUID, with draft: GamingRecordDraft) throws -> GamingRecord {
        let request = GamingRecordEntity.fetchRequest()
        request.predicate = NSPredicate(format: "id == %@", id as CVarArg)
        
        guard let entity = try container.context.fetch(request).first else {
            throw NSError(domain: "RecordNotFound", code: 404)
        }
        
        entity.text = draft.text
        entity.recordDate = draft.recordDate
        entity.imageData = draft.imageData
        entity.updatedAt = Date()
        
        container.saveContext()
        return entity.toRecord()
    }
    
    func archive(_ id: UUID) throws {
        try delete(id)
    }
    
    func delete(_ id: UUID) throws {
        let request = GamingRecordEntity.fetchRequest()
        request.predicate = NSPredicate(format: "id == %@", id as CVarArg)
        
        guard let entity = try container.context.fetch(request).first else {
            throw NSError(domain: "RecordNotFound", code: 404)
        }
        
        container.context.delete(entity)
        container.saveContext()
    }
    
    func active() -> [GamingRecord] {
        let request = GamingRecordEntity.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(key: "updatedAt", ascending: false)]
        
        guard let entities = try? container.context.fetch(request) else {
            return []
        }
        
        return entities.map { $0.toRecord() }
    }
    
    func search(query: String) -> [GamingRecord] {
        let request = GamingRecordEntity.fetchRequest()
        request.predicate = NSPredicate(format: "text CONTAINS[cd] %@", query)
        request.sortDescriptors = [NSSortDescriptor(key: "updatedAt", ascending: false)]
        
        guard let entities = try? container.context.fetch(request) else {
            return []
        }
        
        return entities.map { $0.toRecord() }
    }
}
