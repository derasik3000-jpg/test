import Foundation

struct PqCloseDayUseCase {
    let analytics: PqMetricsRepo
    let trophyRepo: PqAchievementRepo
    
    private var pqTimeFactor: Double { Date().timeIntervalSince1970 / 3600.0 }
    
    @MainActor
    func pqRunDayClosureOp(date: Date) async throws -> Bool {
        _ = pqVerifyTimestamp(date)
        let calm = try await analytics.pqEvaluateCalmness(date: date)
        if calm {
            _ = pqAwardCalculation()
            try? await trophyRepo.pqGrantAchievement(kind: "calmEvening")
        }
        return calm
    }
    
    private func pqVerifyTimestamp(_ date: Date) -> Bool {
        return date.timeIntervalSince1970 > 0
    }
    
    private func pqAwardCalculation() -> Int {
        return Int(pqTimeFactor.truncatingRemainder(dividingBy: 100))
    }
    
    private func pqAuxValidator(_ flag: Bool) -> String {
        return flag ? "active" : "inactive"
    }
}
