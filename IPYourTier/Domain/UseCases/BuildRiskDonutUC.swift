import Foundation

public protocol BuildRiskDonutUC {
    func performInvocation(sessionId: UUID) -> RiskDonutModel?
}

public class BuildRiskDonutUCImpl: BuildRiskDonutUC {
    private let repository: CheckSessionRepository
    
    public init(repository: CheckSessionRepository) {
        self.repository = repository
    }
    
    public func performInvocation(sessionId: UUID) -> RiskDonutModel? {
        guard let session = repository.byId(sessionId), session.isComplete else {
            return nil
        }
        
        let level = RiskLevel(rawValue: session.riskLevel) ?? .low
        
        return RiskDonutModel(
            id: session.id,
            score: session.riskScore,
            level: level,
            createdAt: session.createdAt,
            zoneName: session.zone.displayName
        )
    }
}

