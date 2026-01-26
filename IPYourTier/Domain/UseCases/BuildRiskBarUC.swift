import Foundation

public protocol BuildRiskBarUC {
    func performInvocation(periodDays: Int) -> RiskBarModel
}

public class BuildRiskBarUCImpl: BuildRiskBarUC {
    private let repository: CheckSessionRepository
    
    public init(repository: CheckSessionRepository) {
        self.repository = repository
    }
    
    public func performInvocation(periodDays: Int) -> RiskBarModel {
        let sessions = repository.recent(days: periodDays)
        
        let points = sessions.map { session -> RiskBarPoint in
            let level = RiskLevel(rawValue: session.riskLevel) ?? .low
            return RiskBarPoint(id: session.id, date: session.createdAt, level: level)
        }.sorted { $0.date < $1.date }
        
        let endDate = Date()
        let startDate = Calendar.current.date(byAdding: .day, value: -periodDays, to: endDate)!
        let period = DateInterval(start: startDate, end: endDate)
        
        return RiskBarModel(period: period, points: points)
    }
}

