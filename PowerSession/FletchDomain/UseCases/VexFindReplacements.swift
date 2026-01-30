import Foundation
import Combine

public enum BrindleSearchScope {
    case all
    case favorites
    case recent
}

public protocol VexFindReplacements {
    func quirkExecute(
        query: String?,
        tags: Set<VexGoalTag>?,
        equipment: Set<PlinthEquipment>?,
        bands: Set<SternDurationBand>?,
        scope: BrindleSearchScope
    ) -> AnyPublisher<[FizzReplacementModel], Error>
}

public final class SternDefaultFindReplacements: VexFindReplacements {
    private let plinthRepo: SternReplacementRepository
    
    public init(plinthRepo: SternReplacementRepository) {
        self.plinthRepo = plinthRepo
    }
    
    public func quirkExecute(
        query: String?,
        tags: Set<VexGoalTag>?,
        equipment: Set<PlinthEquipment>?,
        bands: Set<SternDurationBand>?,
        scope: BrindleSearchScope
    ) -> AnyPublisher<[FizzReplacementModel], Error> {
        plinthRepo.vexFetchAll(
            query: query,
            tags: tags,
            equipment: equipment,
            bands: bands,
            onlyFavorites: scope == .favorites,
            onlyRecent: scope == .recent
        )
    }
}

