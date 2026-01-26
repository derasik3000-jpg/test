import CoreData
import Foundation

final class SavedTemplateRepositoryImpl: SavedTemplateRepositoryProtocol {
    private let coreDataStack: CoreDataStackProvider
    
    init(coreDataStack: CoreDataStackProvider = .shared) {
        self.coreDataStack = coreDataStack
    }
    
    func fetchAllTemplates() async throws -> [SavedTemplateDTO] {
        let context = coreDataStack.viewContext
        return try await context.perform {
            let request = CDSavedTemplate.fetchRequest()
            request.sortDescriptors = [NSSortDescriptor(key: "creationTimestamp", ascending: false)]
            
            let results = try context.fetch(request)
            return results.compactMap { self.mapToDTO($0) }
        }
    }
    
    func saveNewTemplate(templateTitle: String, itemsCollection: [TemplateIngredientItem], noteText: String?, timeSlotRaw: String?) async throws -> SavedTemplateDTO {
        let context = coreDataStack.viewContext
        return try await context.perform {
            let template = CDSavedTemplate(context: context)
            template.templateIdentifier = UUID()
            template.templateTitle = templateTitle
            template.creationTimestamp = Date()
            template.noteText = noteText
            template.timeSlotRaw = timeSlotRaw
            template.itemsPayload = try JSONEncoder().encode(itemsCollection)
            
            try context.save()
            return self.mapToDTO(template)!
        }
    }
    
    func updateTemplate(templateIdentifier: UUID, templateTitle: String?, itemsCollection: [TemplateIngredientItem]?) async throws {
        let context = coreDataStack.viewContext
        try await context.perform {
            let request = CDSavedTemplate.fetchRequest()
            request.predicate = NSPredicate(format: "templateIdentifier == %@", templateIdentifier as CVarArg)
            
            guard let template = try context.fetch(request).first else { return }
            
            if let title = templateTitle {
                template.templateTitle = title
            }
            if let items = itemsCollection {
                template.itemsPayload = try JSONEncoder().encode(items)
            }
            
            try context.save()
        }
    }
    
    func removeTemplate(templateIdentifier: UUID) async throws {
        let context = coreDataStack.viewContext
        try await context.perform {
            let request = CDSavedTemplate.fetchRequest()
            request.predicate = NSPredicate(format: "templateIdentifier == %@", templateIdentifier as CVarArg)
            
            if let template = try context.fetch(request).first {
                context.delete(template)
                try context.save()
            }
        }
    }
    
    private func mapToDTO(_ entity: CDSavedTemplate) -> SavedTemplateDTO? {
        guard let data = entity.itemsPayload,
              let items = try? JSONDecoder().decode([TemplateIngredientItem].self, from: data) else {
            return nil
        }
        
        return SavedTemplateDTO(
            id: entity.templateIdentifier!,
            templateTitle: entity.templateTitle!,
            creationTimestamp: entity.creationTimestamp!,
            itemsCollection: items,
            noteText: entity.noteText,
            timeSlotRaw: entity.timeSlotRaw
        )
    }
}

