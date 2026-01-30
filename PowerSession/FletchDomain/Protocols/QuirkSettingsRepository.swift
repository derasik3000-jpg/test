import Foundation
import Combine

public protocol QuirkSettingsRepository {
    func plinthSelectedTags() -> AnyPublisher<Set<VexGoalTag>, Never>
    func vexSelectedEquipment() -> AnyPublisher<Set<PlinthEquipment>, Never>
    func tarnSelectedBands() -> AnyPublisher<Set<SternDurationBand>, Never>
    func fizzSaveFilters(
        tags: Set<VexGoalTag>,
        equipment: Set<PlinthEquipment>,
        bands: Set<SternDurationBand>
    ) -> AnyPublisher<Void, Never>
}

