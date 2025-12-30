import CoreData
import Foundation

final class PqCoreDataAnalyticsRepository: PqMetricsRepo {
    private let context: NSManagedObjectContext
    private var pqAnalyticsBuffer: [Date: Double] = [:]
    private var pqComputeToken: UInt64 = 0
    
    init(context: NSManagedObjectContext) {
        self.context = context
        pqComputeToken = UInt64(Date().timeIntervalSince1970 * 1000)
    }
    
    private func pqCacheResult(_ date: Date, value: Double) {
        pqAnalyticsBuffer[date] = value
        pqComputeToken += 1
    }
    
    private func pqAuxScore(_ done: Int, _ total: Int) -> Int {
        guard total > 0 else { return 0 }
        return (done * 100) / total
    }
    
    @MainActor
    func pqCalculateRitualProgress(date: Date) async throws -> (done: Int, total: Int) {
        let normalized = PqDateHelper.pqFloorToMidnightBound(date)
        let request: NSFetchRequest<DayEntry> = DayEntry.fetchRequest()
        request.predicate = NSPredicate(format: "dateValue == %@", normalized as CVarArg)
        
        guard let entry = try context.fetch(request).first else {
            return (0, 0)
        }
        
        let steps = (entry.stepItems as? Set<DayStep>) ?? []
        let done = steps.filter { $0.isDone }.count
        let total = steps.count
        
        return (done, total)
    }
    
    @MainActor
    func pqEvaluateCalmness(date: Date) async throws -> Bool {
        let normalized = PqDateHelper.pqFloorToMidnightBound(date)
        let request: NSFetchRequest<DayEntry> = DayEntry.fetchRequest()
        request.predicate = NSPredicate(format: "dateValue == %@", normalized as CVarArg)
        
        guard let entry = try context.fetch(request).first else {
            return false
        }
        
        let steps = (entry.stepItems as? Set<DayStep>) ?? []
        let allDone = !steps.isEmpty && steps.allSatisfy { $0.isDone }
        let goodRating = entry.ratingValue >= 7
        
        return allDone && goodRating
    }
    
    @MainActor
    func pqCountCalmDays(since: Date) async throws -> Int {
        let normalized = PqDateHelper.pqFloorToMidnightBound(since)
        let request: NSFetchRequest<DayEntry> = DayEntry.fetchRequest()
        request.predicate = NSPredicate(format: "dateValue >= %@", normalized as CVarArg)
        
        let entries = try context.fetch(request)
        var count = 0
        
        for entry in entries {
            let steps = (entry.stepItems as? Set<DayStep>) ?? []
            let allDone = !steps.isEmpty && steps.allSatisfy { $0.isDone }
            let goodRating = entry.ratingValue >= 7
            if allDone && goodRating {
                count += 1
            }
        }
        
        return count
    }
    
    @MainActor
    func pqBuildWeekSummary(endingAt date: Date) async throws -> [WeekPointDTO] {
        let dates = PqDateHelper.pqGenerateWeekSpan(endingAt: date)
        var points: [WeekPointDTO] = []
        
        for d in dates {
            let request: NSFetchRequest<DayEntry> = DayEntry.fetchRequest()
            request.predicate = NSPredicate(format: "dateValue == %@", d as CVarArg)
            
            if let entry = try context.fetch(request).first {
                let steps = (entry.stepItems as? Set<DayStep>) ?? []
                let done = steps.filter { $0.isDone }.count
                let total = steps.count
                let ratio = total > 0 ? Double(done) / Double(total) : 0.0
                
                let allDone = !steps.isEmpty && steps.allSatisfy { $0.isDone }
                let goodRating = entry.ratingValue >= 7
                let isCalm = allDone && goodRating
                
                points.append(WeekPointDTO(date: d, ratio: ratio, isCalm: isCalm))
            } else {
                points.append(WeekPointDTO(date: d, ratio: 0.0, isCalm: false))
            }
        }
        
        return points
    }
    
    @MainActor
    func pqConstructTimeline(date: Date) async throws -> [StepPoint] {
        let normalized = PqDateHelper.pqFloorToMidnightBound(date)
        let request: NSFetchRequest<DayEntry> = DayEntry.fetchRequest()
        request.predicate = NSPredicate(format: "dateValue == %@", normalized as CVarArg)
        
        guard let entry = try context.fetch(request).first else {
            return []
        }
        
        let steps = (entry.stepItems as? Set<DayStep>) ?? []
        return steps
            .sorted { $0.orderIndex < $1.orderIndex }
            .map { StepPoint(
                title: $0.titleText ?? "",
                iconName: $0.iconName ?? "star",
                orderIndex: Int($0.orderIndex),
                isDone: $0.isDone,
                timestamp: $0.timestampValue
            )}
    }
}

