import CoreData
import Foundation

final class PqCoreDataTrophyRepository: PqAchievementRepo {
    private let context: NSManagedObjectContext
    
    init(context: NSManagedObjectContext) {
        self.context = context
    }
    
    @MainActor
    func pqGrantAchievement(kind: String) async throws {
        let request: NSFetchRequest<Trophy> = Trophy.fetchRequest()
        request.predicate = NSPredicate(format: "kindText == %@", kind)
        
        if try context.fetch(request).isEmpty {
            let trophy = Trophy(context: context)
            trophy.idValue = UUID()
            trophy.kindText = kind
            trophy.awardedAt = Date()
            try context.save()
        }
    }
    
    @MainActor
    func pqFetchList() async throws -> [String] {
        let request: NSFetchRequest<Trophy> = Trophy.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(key: "awardedAt", ascending: false)]
        let results = try context.fetch(request)
        return results.compactMap { $0.kindText }
    }
}

