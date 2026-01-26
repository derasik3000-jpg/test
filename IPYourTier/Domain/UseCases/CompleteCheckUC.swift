import Foundation

public protocol CompleteCheckUC {
    func performInvocation(sessionId: UUID) -> CheckSessionDTO
}

public class CompleteCheckUCImpl: CompleteCheckUC {
    private let repository: CheckSessionRepository
    
    public init(repository: CheckSessionRepository) {
        self.repository = repository
    }
    
    public func performInvocation(sessionId: UUID) -> CheckSessionDTO {
        guard let session = repository.byId(sessionId) else {
            fatalError("Session not found")
        }
        
        let score = calculateRiskScore(session: session)
        let level = determineRiskLevel(score: score, session: session)
        let recommendationCode = level
        
        return repository.complete(
            sessionId: sessionId,
            riskScore: score,
            riskLevel: level,
            recommendationCode: recommendationCode
        )
    }
    
    private func calculateRiskScore(session: CheckSessionDTO) -> Int {
        var score = 0
        
        if session.painRest {
            score += 2
        }
        
        if session.popSound {
            score += 3
        }
        
        if session.edema {
            score += 1
        }
        if session.heat {
            score += 1
        }
        if session.instability {
            score += 1
        }
        
        if session.romPercent <= 60 {
            score += 2
        } else if session.romPercent <= 80 {
            score += 1
        }
        
        if session.painNRS >= 7 {
            score += 2
        } else if session.painNRS >= 4 {
            score += 1
        }
        
        if session.morningStiffness {
            score += 1
        }
        
        if session.betterWithLoadReduction == 1 {
            score -= 1
        }
        
        if session.symptomStart >= 3 {
            score += 2
        } else if session.symptomStart >= 2 {
            score += 1
        }
        
        return max(0, score)
    }
    
    private func determineRiskLevel(score: Int, session: CheckSessionDTO) -> Int {
        if session.redFlag {
            return RiskLevel.red.rawValue
        }
        
        if score >= 6 {
            return RiskLevel.high.rawValue
        } else if score >= 3 {
            return RiskLevel.medium.rawValue
        } else {
            return RiskLevel.low.rawValue
        }
    }
}

