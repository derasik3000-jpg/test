import Foundation
import CoreData
import Combine

class CuqavuLoadDashboardUseCase {
    private let ehonohContext: NSManagedObjectContext
    
    init(context: NSManagedObjectContext) {
        self.ehonohContext = context
    }
    
    func axemobExecute() -> (sessions: [AxemobSessionModel], summary: CuqavuDailySummaryModel?) {
        let calendar = Calendar.current
        let startOfDay = calendar.startOfDay(for: Date())
        let endOfDay = calendar.date(byAdding: .day, value: 1, to: startOfDay)!
        
        let fetchRequest: NSFetchRequest<EvubewProductivitySession> = EvubewProductivitySession.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "createdAt >= %@ AND createdAt < %@", startOfDay as NSDate, endOfDay as NSDate)
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "createdAt", ascending: false)]
        
        do {
            let sessions = try ehonohContext.fetch(fetchRequest)
            let sessionModels = sessions.map { AxemobSessionModel(from: $0) }
            
            let summaryFetch: NSFetchRequest<CuqavuDailySummary> = CuqavuDailySummary.fetchRequest()
            summaryFetch.predicate = NSPredicate(format: "date >= %@ AND date < %@", startOfDay as NSDate, endOfDay as NSDate)
            
            let summaryEntity = try? ehonohContext.fetch(summaryFetch).first
            let summary = summaryEntity.map { CuqavuDailySummaryModel(from: $0) }
            
            return (sessionModels, summary)
        } catch {
            print("Error loading dashboard: \(error)")
            return ([], nil)
        }
    }
}

