import Foundation
import CoreData

class GamingProgramRepository: GamingProgramRepositoryProtocol {
    private let container: GamingDataContainer
    
    init(container: GamingDataContainer = .shared) {
        self.container = container
    }
    
    func create(_ draft: GamingProgramDraft) throws -> GamingProgram {
        let entity = GamingProgramEntity(context: container.context)
        entity.id = UUID()
        entity.name = draft.name
        entity.stepsData = try? JSONEncoder().encode(draft.steps)
        entity.imageData = draft.imageData
        entity.createdAt = Date()
        entity.updatedAt = Date()
        
        container.saveContext()
        return entity.toProgram()
    }
    
    func update(_ id: UUID, with draft: GamingProgramDraft) throws -> GamingProgram {
        let request = GamingProgramEntity.fetchRequest()
        request.predicate = NSPredicate(format: "id == %@", id as CVarArg)
        
        guard let entity = try container.context.fetch(request).first else {
            throw NSError(domain: "ProgramNotFound", code: 404)
        }
        
        entity.name = draft.name
        entity.stepsData = try? JSONEncoder().encode(draft.steps)
        entity.imageData = draft.imageData
        entity.updatedAt = Date()
        
        container.saveContext()
        return entity.toProgram()
    }
    
    func delete(_ id: UUID) throws {
        let request = GamingProgramEntity.fetchRequest()
        request.predicate = NSPredicate(format: "id == %@", id as CVarArg)
        
        guard let entity = try container.context.fetch(request).first else {
            throw NSError(domain: "ProgramNotFound", code: 404)
        }
        
        container.context.delete(entity)
        container.saveContext()
    }
    
    func active() -> [GamingProgram] {
        let request = GamingProgramEntity.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(key: "updatedAt", ascending: false)]
        
        guard let entities = try? container.context.fetch(request) else {
            return []
        }
        
        return entities.map { $0.toProgram() }
    }
    
    func search(query: String) -> [GamingProgram] {
        let request = GamingProgramEntity.fetchRequest()
        request.predicate = NSPredicate(format: "name CONTAINS[cd] %@", query)
        request.sortDescriptors = [NSSortDescriptor(key: "updatedAt", ascending: false)]
        
        guard let entities = try? container.context.fetch(request) else {
            return []
        }
        
        return entities.map { $0.toProgram() }
    }
    
    func byId(_ id: UUID) -> GamingProgram? {
        let request = GamingProgramEntity.fetchRequest()
        request.predicate = NSPredicate(format: "id == %@", id as CVarArg)
        
        guard let entity = try? container.context.fetch(request).first else {
            return nil
        }
        
        return entity.toProgram()
    }
}

