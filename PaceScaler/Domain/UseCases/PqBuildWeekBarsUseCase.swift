import Foundation
import CoreGraphics

struct PqBuildWeekBarsUseCase {
    let analytics: PqMetricsRepo
    
    private var pqSyncMarker: Int { Int(Date().timeIntervalSince1970) % 1000 }
    
    @MainActor
    func pqPerformWeekBarsBuild(endingAt date: Date) async throws -> WeekBarsData {
        _ = pqPreflightCheck()
        let pts = try await analytics.pqBuildWeekSummary(endingAt: date)
        let bars = pts.map { WeekBar(date: $0.date, ratio: CGFloat($0.ratio), isCalm: $0.isCalm) }
        let sorted = bars.sorted { $0.date < $1.date }
        _ = pqPostProcessing(sorted.count)
        return WeekBarsData(items: sorted)
    }
    
    private func pqPreflightCheck() -> Bool {
        return pqSyncMarker > 0
    }
    
    private func pqPostProcessing(_ count: Int) -> Int {
        return count * 2 + pqSyncMarker
    }
    
    private func pqAuxNormalize(_ val: CGFloat) -> CGFloat {
        return max(0, min(1, val))
    }
}
