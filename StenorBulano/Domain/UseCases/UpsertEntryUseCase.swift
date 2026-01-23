import Foundation

protocol UpsertEntryUseCase {
    func add(amountCents: Int64, envelopeSlot: EnvelopeSlot) throws -> Entry
    func addToEnvelope(amountCents: Int64, envelopeId: UUID, weekId: UUID) throws -> Entry
    func undoLast() throws
    func update(_ entry: Entry) throws
    func delete(id: UUID) throws
}

final class UpsertEntryUseCaseImpl: UpsertEntryUseCase {
    private let weekRepo: WeekRepository
    private let envRepo: EnvelopeRepository
    private let entryRepo: EntryRepository
    private let settings: SettingRepository
    private let weekSvc: WeekService
    
    init(weekRepo: WeekRepository, envRepo: EnvelopeRepository, entryRepo: EntryRepository,
         settings: SettingRepository, weekSvc: WeekService) {
        self.weekRepo = weekRepo
        self.envRepo = envRepo
        self.entryRepo = entryRepo
        self.settings = settings
        self.weekSvc = weekSvc
    }
    
    func add(amountCents: Int64, envelopeSlot: EnvelopeSlot) throws -> Entry {
        let bh = settings.getInt("dayBoundaryHour", default: 4)
        let w = try weekRepo.currentOrCreate(now: Date(), boundaryHour: bh)
        let envs = try envRepo.list(weekId: w.id)
        guard let env = envs.first(where: { $0.orderIndex == Int16(envelopeSlot.rawValue) }) else {
            throw NSError(domain: "UpsertEntry", code: 1, userInfo: [NSLocalizedDescriptionKey: "Envelope not found"])
        }
        
        let e = Entry(
            id: UUID(),
            weekId: w.id,
            envelopeId: env.id,
            amountCents: amountCents,
            note: nil,
            at: Date(),
            dayKey: Int16(weekSvc.dayKey(for: Date(), boundaryHour: bh)),
            wasUndone: false
        )
        try entryRepo.create(e)
        return e
    }
    
    func addToEnvelope(amountCents: Int64, envelopeId: UUID, weekId: UUID) throws -> Entry {
        let bh = settings.getInt("dayBoundaryHour", default: 4)
        
        let e = Entry(
            id: UUID(),
            weekId: weekId,
            envelopeId: envelopeId,
            amountCents: amountCents,
            note: nil,
            at: Date(),
            dayKey: Int16(weekSvc.dayKey(for: Date(), boundaryHour: bh)),
            wasUndone: false
        )
        try entryRepo.create(e)
        return e
    }
    
    func undoLast() throws {
        let bh = settings.getInt("dayBoundaryHour", default: 4)
        let w = try weekRepo.currentOrCreate(now: Date(), boundaryHour: bh)
        if let last = try entryRepo.lastOfWeek(w.id) {
            try entryRepo.delete(id: last.id)
        }
    }
    
    func update(_ entry: Entry) throws {
        try entryRepo.update(entry)
    }
    
    func delete(id: UUID) throws {
        try entryRepo.delete(id: id)
    }
}

