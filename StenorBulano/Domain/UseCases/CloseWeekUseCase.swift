import Foundation

protocol CloseWeekUseCase {
    func execute(weekId: UUID) throws -> (Week, Bool)
}

final class CloseWeekUseCaseImpl: CloseWeekUseCase {
    private let weekRepo: WeekRepository
    private let envRepo: EnvelopeRepository
    private let badgeRepo: BadgeRepository
    private let balance: BalanceCalculator
    
    init(weekRepo: WeekRepository, envRepo: EnvelopeRepository, badgeRepo: BadgeRepository, balance: BalanceCalculator) {
        self.weekRepo = weekRepo
        self.envRepo = envRepo
        self.badgeRepo = badgeRepo
        self.balance = balance
    }
    
    func execute(weekId: UUID) throws -> (Week, Bool) {
        guard var w = try weekRepo.byId(weekId) else {
            throw NSError(domain: "CloseWeek", code: 1, userInfo: [NSLocalizedDescriptionKey: "Week not found"])
        }
        let env = try envRepo.list(weekId: weekId)
        let snap = balance.weeklySkew(envelopes: env)
        
        w.status = 1
        w.closedAt = Date()
        w.maxDeltaPct = Int16(round(abs(snap.maxDeltaPct)))
        try weekRepo.save(w)
        
        var badge = false
        if snap.status == .ok {
            try badgeRepo.insert(Badge(id: UUID(), weekId: weekId, kind: 0, achievedAt: Date()))
            badge = true
        }
        return (w, badge)
    }
}

