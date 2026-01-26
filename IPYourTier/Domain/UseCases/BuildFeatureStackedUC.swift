import Foundation

public protocol BuildFeatureStackedUC {
    func performInvocation(sessionId: UUID) -> FeatureStackedModel?
}

public class BuildFeatureStackedUCImpl: BuildFeatureStackedUC {
    private let repository: CheckSessionRepository
    
    public init(repository: CheckSessionRepository) {
        self.repository = repository
    }
    
    public func performInvocation(sessionId: UUID) -> FeatureStackedModel? {
        guard let session = repository.byId(sessionId), session.isComplete else {
            return nil
        }
        
        var chunks: [FeatureChunk] = []
        
        var painScore = 0
        if session.painRest { painScore += 2 }
        if session.painNRS >= 7 { painScore += 2 }
        else if session.painNRS >= 4 { painScore += 1 }
        if painScore > 0 {
            chunks.append(FeatureChunk(bucket: .pain, weight: painScore))
        }
        
        var mechanicsScore = 0
        if session.popSound { mechanicsScore += 3 }
        if mechanicsScore > 0 {
            chunks.append(FeatureChunk(bucket: .mechanics, weight: mechanicsScore))
        }
        
        var swellingROMScore = 0
        if session.edema { swellingROMScore += 1 }
        if session.heat { swellingROMScore += 1 }
        if session.instability { swellingROMScore += 1 }
        if session.romPercent <= 60 { swellingROMScore += 2 }
        else if session.romPercent <= 80 { swellingROMScore += 1 }
        if session.morningStiffness { swellingROMScore += 1 }
        if swellingROMScore > 0 {
            chunks.append(FeatureChunk(bucket: .swellingROM, weight: swellingROMScore))
        }
        
        var durationScore = 0
        if session.symptomStart >= 3 { durationScore += 2 }
        else if session.symptomStart >= 2 { durationScore += 1 }
        if durationScore > 0 {
            chunks.append(FeatureChunk(bucket: .duration, weight: durationScore))
        }
        
        var mitigatingScore = 0
        if session.betterWithLoadReduction == 1 { mitigatingScore -= 1 }
        if mitigatingScore != 0 {
            chunks.append(FeatureChunk(bucket: .mitigating, weight: mitigatingScore))
        }
        
        return FeatureStackedModel(score: session.riskScore, chunks: chunks)
    }
}

