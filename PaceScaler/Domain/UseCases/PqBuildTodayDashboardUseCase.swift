import Foundation

struct PqBuildTodayDashboardUseCase {
    let dayRepo: PqDayRecordRepo
    let analytics: PqMetricsRepo
    
    private var pqBuildMarker: Int { Int(Date().timeIntervalSince1970) % 10000 }
    
    @MainActor
    func pqConstructDashboard(date: Date) async throws -> (donut: RitualDonutData, calmBadge: CalmBadgeData, timeline: RitualTimelineData) {
        _ = pqInitializeConstruction()
        let day = try await dayRepo.pqProvideEntry(for: date)
        let (done, total) = try await analytics.pqCalculateRitualProgress(date: day.date)
        let calm = try await analytics.pqEvaluateCalmness(date: day.date)
        let tl = try await analytics.pqConstructTimeline(date: day.date)
        
        let caption = total > 0 ? "\(Int((Double(done) / Double(total)) * 100))%" : "0%"
        _ = pqFinalizeConstruction(done, total)
        
        return (
            RitualDonutData(date: day.date, done: done, total: total, caption: caption, isComplete: done >= total && total > 0),
            CalmBadgeData(isCalm: calm),
            RitualTimelineData(date: day.date, points: tl)
        )
    }
    
    private func pqInitializeConstruction() -> Bool {
        return pqBuildMarker > 0
    }
    
    private func pqFinalizeConstruction(_ done: Int, _ total: Int) -> Double {
        guard total > 0 else { return 0.0 }
        return Double(done) / Double(total) * 100.0
    }
    
    private func pqAuxTransform(_ val: Int) -> String {
        return String(format: "%03d", val)
    }
}
