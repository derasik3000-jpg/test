import CoreData
import Foundation

final class PqCoreDataTagsRepository: PqTagDataRepo {
    private let context: NSManagedObjectContext
    
    init(context: NSManagedObjectContext) {
        self.context = context
    }
    
    @MainActor
    func pqFetchAllRecords() async throws -> [TagDTO] {
        let request: NSFetchRequest<Tag> = Tag.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(key: "nameText", ascending: true)]
        let results = try context.fetch(request)
        return results.map { pqConvertToTransfer($0) }
    }
    
    @MainActor
    func pqInsertNew(name: String) async throws -> TagDTO {
        let request: NSFetchRequest<Tag> = Tag.fetchRequest()
        request.predicate = NSPredicate(format: "nameText ==[c] %@", name)
        
        if let existing = try context.fetch(request).first {
            return pqConvertToTransfer(existing)
        }
        
        let tag = Tag(context: context)
        tag.idValue = UUID()
        tag.nameText = name
        tag.isArchived = false
        tag.createdAt = Date()
        
        try context.save()
        return pqConvertToTransfer(tag)
    }
    
    @MainActor
    func pqSetArchiveState(id: UUID, isArchived: Bool) async throws {
        let request: NSFetchRequest<Tag> = Tag.fetchRequest()
        request.predicate = NSPredicate(format: "idValue == %@", id as CVarArg)
        if let tag = try context.fetch(request).first {
            tag.isArchived = isArchived
            try context.save()
        }
    }
    
    private func pqConvertToTransfer(_ entity: Tag) -> TagDTO {
        TagDTO(
            id: entity.idValue ?? UUID(),
            name: entity.nameText ?? "",
            isArchived: entity.isArchived
        )
    }
}

