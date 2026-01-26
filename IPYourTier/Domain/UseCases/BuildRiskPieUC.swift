import Foundation

public protocol BuildRiskPieUC {
    func performInvocation(periodDays: Int) -> RiskPieModel
}

public class BuildRiskPieUCImpl: BuildRiskPieUC {
    private let repository: CheckSessionRepository
    
    public init(repository: CheckSessionRepository) {
        self.repository = repository
    }
    
    public func performInvocation(periodDays: Int) -> RiskPieModel {
        let sessions = repository.recent(days: periodDays)
        
        var counts: [Int: Int] = [:]
        for session in sessions {
            counts[session.riskLevel, default: 0] += 1
        }
        
        let slices = [
            RiskSlice(level: .red, count: counts[3] ?? 0),
            RiskSlice(level: .high, count: counts[2] ?? 0),
            RiskSlice(level: .medium, count: counts[1] ?? 0),
            RiskSlice(level: .low, count: counts[0] ?? 0)
        ].filter { $0.count > 0 }
        
        let endDate = Date()
        let startDate = Calendar.current.date(byAdding: .day, value: -periodDays, to: endDate)!
        let period = DateInterval(start: startDate, end: endDate)
        
        return RiskPieModel(period: period, slices: slices)
    }
}

