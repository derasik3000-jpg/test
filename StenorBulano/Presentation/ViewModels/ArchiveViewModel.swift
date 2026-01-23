import Foundation
import Combine

final class ArchiveViewModel: ObservableObject {
    @Published var weeks: [Week] = []
    
    private let weekRepo: WeekRepository
    private let envRepo: EnvelopeRepository
    private let badgeRepo: BadgeRepository
    
    init(weekRepo: WeekRepository, envRepo: EnvelopeRepository, badgeRepo: BadgeRepository) {
        self.weekRepo = weekRepo
        self.envRepo = envRepo
        self.badgeRepo = badgeRepo
    }
    
    func load() {
        weeks = (try? weekRepo.allWeeks()) ?? []
    }
    
    func envelopes(for weekId: UUID) -> [WeekEnvelope] {
        return (try? envRepo.list(weekId: weekId)) ?? []
    }
    
    func badges(for weekId: UUID) -> [Badge] {
        return (try? badgeRepo.byWeek(weekId)) ?? []
    }
}

