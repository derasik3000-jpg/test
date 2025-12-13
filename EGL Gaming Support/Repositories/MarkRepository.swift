import Foundation
import CoreData

class GamingMarkRepository: GamingMarkRepositoryProtocol {
    private let container: GamingDataContainer
    
    init(container: GamingDataContainer = .shared) {
        self.container = container
    }
    
    func upsert(date: Date, delta: Int, note: String?) throws -> GamingMark {
        let calendar = Calendar.current
        let startOfDay = calendar.startOfDay(for: date)
        let endOfDay = calendar.date(byAdding: .day, value: 1, to: startOfDay)!
        
        let request = GamingMarkEntity.fetchRequest()
        request.predicate = NSPredicate(format: "markDate >= %@ AND markDate < %@", startOfDay as CVarArg, endOfDay as CVarArg)
        
        let existing = try? container.context.fetch(request).first
        
        let entity: GamingMarkEntity
        if let existing = existing {
            entity = existing
            entity.count = max(0, entity.count + Int32(delta))
            if let note = note {
                entity.note = note
            }
        } else {
            entity = GamingMarkEntity(context: container.context)
            entity.id = UUID()
            entity.markDate = startOfDay
            entity.count = max(0, Int32(delta))
            entity.note = note
        }
        
        container.saveContext()
        return entity.toMark()
    }
    
    func range(from: Date, to: Date) -> [GamingMark] {
        let request = GamingMarkEntity.fetchRequest()
        request.predicate = NSPredicate(format: "markDate >= %@ AND markDate <= %@", from as CVarArg, to as CVarArg)
        request.sortDescriptors = [NSSortDescriptor(key: "markDate", ascending: true)]
        
        guard let entities = try? container.context.fetch(request) else {
            return []
        }
        
        return entities.map { $0.toMark() }
    }
    
    func totalCount() -> Int32 {
        let request = GamingMarkEntity.fetchRequest()
        guard let entities = try? container.context.fetch(request) else {
            return 0
        }
        
        return entities.reduce(0) { $0 + $1.count }
    }
}

