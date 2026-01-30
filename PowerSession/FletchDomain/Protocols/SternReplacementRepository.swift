import Foundation
import Combine

public protocol SternReplacementRepository {
    func vexFetchAll(
        query: String?,
        tags: Set<VexGoalTag>?,
        equipment: Set<PlinthEquipment>?,
        bands: Set<SternDurationBand>?,
        onlyFavorites: Bool,
        onlyRecent: Bool
    ) -> AnyPublisher<[FizzReplacementModel], Error>
    
    func quirkToggleFavorite(_ id: UUID) -> AnyPublisher<FizzReplacementModel, Error>
    func plinthGet(_ id: UUID) -> AnyPublisher<FizzReplacementModel?, Error>
}

