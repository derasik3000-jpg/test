import Foundation
import CoreData

class DegubaCalculateSummaryUseCase {
    private let axemobContext: NSManagedObjectContext
    
    init(context: NSManagedObjectContext) {
        self.axemobContext = context
    }
    
    func evubewExecuteForDate(_ date: Date) -> CuqavuDailySummaryModel? {
        let calendar = Calendar.current
        let startOfDay = calendar.startOfDay(for: date)
        let endOfDay = calendar.date(byAdding: .day, value: 1, to: startOfDay)!
        
        let fetchRequest: NSFetchRequest<EvubewProductivitySession> = EvubewProductivitySession.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "createdAt >= %@ AND createdAt < %@", startOfDay as NSDate, endOfDay as NSDate)
        
        do {
            let sessions = try axemobContext.fetch(fetchRequest)
            
            if sessions.isEmpty {
                return nil
            }
            
            var totalWork: Int32 = 0
            var totalStudy: Int32 = 0
            var totalSport: Int32 = 0
            var totalRest: Int32 = 0
            var totalEnergy: Double = 0
            var totalMood: Double = 0
            
            for session in sessions {
                let duration = Int32(session.durationMin)
                
                switch EhonohSessionType(rawValue: session.type) {
                case .work:
                    totalWork += duration
                case .study:
                    totalStudy += duration
                case .sport:
                    totalSport += duration
                case .rest:
                    totalRest += duration
                default:
                    break
                }
                
                totalEnergy += Double(session.energyLevel)
                totalMood += Double(session.mood)
            }
            
            let avgEnergy = totalEnergy / Double(sessions.count)
            let avgMood = totalMood / Double(sessions.count)
            
            let summaryFetch: NSFetchRequest<CuqavuDailySummary> = CuqavuDailySummary.fetchRequest()
            summaryFetch.predicate = NSPredicate(format: "date >= %@ AND date < %@", startOfDay as NSDate, endOfDay as NSDate)
            
            let existingSummary = try? axemobContext.fetch(summaryFetch).first
            let summary = existingSummary ?? CuqavuDailySummary(context: axemobContext)
            
            if existingSummary == nil {
                summary.id = UUID()
                summary.date = startOfDay
            }
            
            summary.totalWorkMin = totalWork
            summary.totalStudyMin = totalStudy
            summary.totalSportMin = totalSport
            summary.totalRestMin = totalRest
            summary.avgEnergy = avgEnergy
            summary.avgMood = avgMood
            
            try axemobContext.save()
            
            return CuqavuDailySummaryModel(from: summary)
        } catch {
            print("Error calculating summary: \(error)")
            return nil
        }
    }
}

