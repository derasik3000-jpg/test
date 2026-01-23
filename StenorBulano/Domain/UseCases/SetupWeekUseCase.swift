import Foundation

protocol SetupWeekUseCase {
    func currentWeek() throws -> (Week, [WeekEnvelope])
    func renameEnvelopes(weekId: UUID, names: [String]) throws -> [WeekEnvelope]
}

final class SetupWeekUseCaseImpl: SetupWeekUseCase {
    private let weekRepo: WeekRepository
    private let envRepo: EnvelopeRepository
    private let settings: SettingRepository
    private let weekSvc: WeekService
    
    init(weekRepo: WeekRepository, envRepo: EnvelopeRepository, settings: SettingRepository, weekSvc: WeekService) {
        self.weekRepo = weekRepo
        self.envRepo = envRepo
        self.settings = settings
        self.weekSvc = weekSvc
    }
    
    func currentWeek() throws -> (Week, [WeekEnvelope]) {
        let bh = settings.getInt("dayBoundaryHour", default: 4)
        let w = try weekRepo.currentOrCreate(now: Date(), boundaryHour: bh)
        let env = try envRepo.list(weekId: w.id)
        return (w, env)
    }
    
    func renameEnvelopes(weekId: UUID, names: [String]) throws -> [WeekEnvelope] {
        guard names.count >= 1 else {
            throw NSError(domain: "SetupWeek", code: 1, userInfo: [NSLocalizedDescriptionKey: "At least one envelope required"])
        }
        return try envRepo.upsertNames(weekId: weekId, names: names)
    }
}

