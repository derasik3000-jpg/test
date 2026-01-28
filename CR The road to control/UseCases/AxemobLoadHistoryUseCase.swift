import Foundation
import CoreData

class AxemobLoadHistoryUseCase {
    private let degubaContext: NSManagedObjectContext
    
    init(context: NSManagedObjectContext) {
        self.degubaContext = context
    }
    
    func evubewExecute(filterType: EhonohSessionType? = nil, days: Int = 30) -> [AxemobSessionModel] {
        let fetchRequest: NSFetchRequest<EvubewProductivitySession> = EvubewProductivitySession.fetchRequest()
        
        let calendar = Calendar.current
        let startDate = calendar.date(byAdding: .day, value: -days, to: Date())!
        
        var predicates: [NSPredicate] = [NSPredicate(format: "createdAt >= %@", startDate as NSDate)]
        
        if let filterType = filterType {
            predicates.append(NSPredicate(format: "type == %d", filterType.rawValue))
        }
        
        fetchRequest.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: predicates)
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "createdAt", ascending: false)]
        
        do {
            let sessions = try degubaContext.fetch(fetchRequest)
            return sessions.map { AxemobSessionModel(from: $0) }
        } catch {
            print("Error loading history: \(error)")
            return []
        }
    }
    
    func cuqavuLoadSummaries(days: Int = 30) -> [CuqavuDailySummaryModel] {
        let fetchRequest: NSFetchRequest<CuqavuDailySummary> = CuqavuDailySummary.fetchRequest()
        
        let calendar = Calendar.current
        let startDate = calendar.date(byAdding: .day, value: -days, to: Date())!
        
        fetchRequest.predicate = NSPredicate(format: "date >= %@", startDate as NSDate)
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "date", ascending: false)]
        
        do {
            let summaries = try degubaContext.fetch(fetchRequest)
            return summaries.map { CuqavuDailySummaryModel(from: $0) }
        } catch {
            print("Error loading summaries: \(error)")
            return []
        }
    }
}

