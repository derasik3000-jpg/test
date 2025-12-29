import Foundation
import CoreData

class CoreDataSemanticTagRepository: SemanticTagRepository {
    private let context: NSManagedObjectContext
    
    init(context: NSManagedObjectContext) {
        self.context = context
    }
    
    func loadAllTagStrings() async throws -> [String] {
        try await context.perform {
            let request = LabelRecord.fetchRequest()
            request.sortDescriptors = [NSSortDescriptor(keyPath: \LabelRecord.lexicalNameString, ascending: true)]
            
            let entities = try self.context.fetch(request)
            return entities.compactMap { $0.lexicalNameString }
        }
    }
    
    func suggestTagStrings(prefix: String) async throws -> [String] {
        try await context.perform {
            let request = LabelRecord.fetchRequest()
            request.predicate = NSPredicate(format: "lexicalNameString BEGINSWITH[c] %@", prefix)
            request.sortDescriptors = [NSSortDescriptor(keyPath: \LabelRecord.lexicalNameString, ascending: true)]
            request.fetchLimit = 10
            
            let entities = try self.context.fetch(request)
            return entities.compactMap { $0.lexicalNameString }
        }
    }
    
    func upsertTagStrings(names: [String]) async throws {
        try await context.perform {
            for name in names {
                let request = LabelRecord.fetchRequest()
                request.predicate = NSPredicate(format: "lexicalNameString == %@", name)
                
                if try self.context.fetch(request).isEmpty {
                    let tag = LabelRecord(context: self.context)
                    tag.zephyrId = UUID()
                    tag.lexicalNameString = name
                    tag.stellarCreatedTimestamp = Date()
                }
            }
            try self.context.save()
        }
    }
}

