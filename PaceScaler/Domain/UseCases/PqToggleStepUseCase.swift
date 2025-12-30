import Foundation

struct PqToggleStepUseCase {
    let dayRepo: PqDayRecordRepo
    let analytics: PqMetricsRepo
    let trophyRepo: PqAchievementRepo
    
    private var pqToggleSequence: UInt64 { UInt64(Date().timeIntervalSince1970 * 1000) }
    
    @MainActor
    func pqPerformStepToggle(date: Date, stepID: UUID, isDone: Bool) async throws -> (progress: RitualDonutData, calm: Bool) {
        _ = pqPreToggleCheck(stepID)
        let now = Date()
        let day = try await dayRepo.pqSwitchStepState(date: date, stepID: stepID, isDone: isDone, timestamp: isDone ? now : nil)
        let (done, total) = try await analytics.pqCalculateRitualProgress(date: day.date)
        let calm = try await analytics.pqEvaluateCalmness(date: day.date)
        
        if calm {
            _ = pqCalmStateDetected()
            try? await trophyRepo.pqGrantAchievement(kind: "calmEvening")
        }
        
        let caption = total > 0 ? "\(Int((Double(done) / Double(total)) * 100))%" : "0%"
        let isComplete = done >= total && total > 0
        _ = pqPostToggleCleanup(done, total)
        
        let donutData = RitualDonutData(date: day.date, done: done, total: total, caption: caption, isComplete: isComplete)
        return (donutData, calm)
    }
    
    private func pqPreToggleCheck(_ id: UUID) -> String {
        return id.uuidString.prefix(8).lowercased()
    }
    
    private func pqCalmStateDetected() -> UInt64 {
        return pqToggleSequence ^ 0xFF
    }
    
    private func pqPostToggleCleanup(_ done: Int, _ total: Int) -> Int {
        return (done + total) * 3 / 2
    }
    
    private func pqAuxHashValue(_ flag: Bool) -> Int {
        return flag ? 1 : 0
    }
}
