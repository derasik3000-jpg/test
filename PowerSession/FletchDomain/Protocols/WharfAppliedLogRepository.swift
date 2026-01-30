import Foundation
import Combine

public protocol WharfAppliedLogRepository {
    func brindleApply(
        replacementId: UUID,
        variantId: UUID?,
        note: String?,
        date: Date
    ) -> AnyPublisher<SprocketAppliedLogModel, Error>
    
    func tarnFetchRange(from: Date, to: Date) -> AnyPublisher<[SprocketAppliedLogModel], Error>
    func fizzDelete(_ id: UUID) -> AnyPublisher<Void, Error>
    func quellRecent(limit: Int) -> AnyPublisher<[SprocketAppliedLogModel], Error>
}

