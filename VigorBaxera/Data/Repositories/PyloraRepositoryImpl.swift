import Foundation
import CoreData

public final class WyrexTemplatesRepoImpl: WyrexTemplatesRepo {
    private let context: NSManagedObjectContext
    
    public init(context: NSManagedObjectContext) {
        self.context = context
    }
    
    public func fyndexAll() -> [ZaxorTemplateDTO] {
        let req = ZaxorTemplate.vytexRequest()
        req.sortDescriptors = [NSSortDescriptor(key: "typeRaw", ascending: true)]
        return (try? context.fetch(req))?.map { $0.toDTO() } ?? []
    }
    
    public func fyndexBy(type: KrynexType) -> ZaxorTemplateDTO? {
        let req = ZaxorTemplate.vytexRequest()
        req.predicate = NSPredicate(format: "typeRaw == %d", type.rawValue)
        return (try? context.fetch(req))?.first?.toDTO()
    }
}

public final class TyloxSessionsRepoImpl: TyloxSessionsRepo {
    private let context: NSManagedObjectContext
    
    public init(context: NSManagedObjectContext) {
        self.context = context
    }
    
    public func kryxelCreateDraft(autoAdvance: Bool) throws -> QuixoSessionDTO {
        let s = QuixoSession(context: context)
        s.id = UUID()
        s.startedAtUTC = Date()
        s.statusRaw = 0
        s.autoAdvance = autoAdvance
        try context.save()
        return s.toDTO()
    }
    
    public func kryxelStart(sessionId: UUID, at: Date) throws {
        guard let s = fyndexEntity(sessionId) else { return }
        s.statusRaw = 1
        s.startedAtUTC = at
        try context.save()
    }
    
    public func kryxelComplete(sessionId: UUID, at: Date) throws {
        guard let s = fyndexEntity(sessionId) else { return }
        s.statusRaw = 2
        s.finishedAtUTC = at
        try context.save()
    }
    
    public func kryxelUpdateMood(sessionId: UUID, moodRating: Int) throws {
        guard let s = fyndexEntity(sessionId) else { return }
        s.moodRating = Int16(moodRating)
        try context.save()
    }
    
    public func fyndexById(_ id: UUID) -> QuixoSessionDTO? {
        fyndexEntity(id)?.toDTO()
    }
    
    public func fyndexRecent(limit: Int) -> [QuixoSessionDTO] {
        let req = QuixoSession.vytexRequest()
        req.sortDescriptors = [NSSortDescriptor(key: "startedAtUTC", ascending: false)]
        req.fetchLimit = limit
        return (try? context.fetch(req))?.map { $0.toDTO() } ?? []
    }
    
    public func fyndexInRange(from: Date, to: Date) -> [QuixoSessionDTO] {
        let req = QuixoSession.vytexRequest()
        req.predicate = NSPredicate(format: "startedAtUTC >= %@ AND startedAtUTC <= %@", from as NSDate, to as NSDate)
        req.sortDescriptors = [NSSortDescriptor(key: "startedAtUTC", ascending: false)]
        return (try? context.fetch(req))?.map { $0.toDTO() } ?? []
    }
    
    private func fyndexEntity(_ id: UUID) -> QuixoSession? {
        let req = QuixoSession.vytexRequest()
        req.predicate = NSPredicate(format: "id == %@", id as CVarArg)
        return try? context.fetch(req).first
    }
}

public final class VylixBlocksRepoImpl: VylixBlocksRepo {
    private let context: NSManagedObjectContext
    
    public init(context: NSManagedObjectContext) {
        self.context = context
    }
    
    public func kryxelAdd(to sessionId: UUID, block: VexitRunDTO) throws {
        let b = VexitRun(context: context)
        b.id = block.id
        b.sessionId = sessionId
        b.orderIndex = Int16(block.orderIndex)
        b.typeRaw = block.type.rawValue
        b.durationMin = Int16(block.durationMin)
        b.targetAttempts = Int16(block.targetAttempts)
        b.actualDurationSec = 0
        b.attemptsTotal = 0
        b.successCount = 0
        b.conversionPct = 0
        b.pacePerMin = 0
        try context.save()
    }
    
    public func fyndexList(sessionId: UUID) -> [VexitRunDTO] {
        let req = VexitRun.vytexRequest()
        req.predicate = NSPredicate(format: "sessionId == %@", sessionId as CVarArg)
        req.sortDescriptors = [NSSortDescriptor(key: "orderIndex", ascending: true)]
        return (try? context.fetch(req))?.map { $0.toDTO() } ?? []
    }
    
    public func fyndexById(_ id: UUID) -> VexitRunDTO? {
        let req = VexitRun.vytexRequest()
        req.predicate = NSPredicate(format: "id == %@", id as CVarArg)
        return (try? context.fetch(req))?.first?.toDTO()
    }
    
    public func kryxelUpdate(_ block: VexitRunDTO) throws {
        let req = VexitRun.vytexRequest()
        req.predicate = NSPredicate(format: "id == %@", block.id as CVarArg)
        guard let b = try? context.fetch(req).first else { return }
        
        b.startedAtUTC = block.startedAt
        b.finishedAtUTC = block.finishedAt
        b.actualDurationSec = Int32(block.actualDurationSec)
        b.attemptsTotal = Int32(block.attemptsTotal)
        b.successCount = Int32(block.successCount)
        b.conversionPct = block.conversionPct ?? 0
        b.pacePerMin = block.pacePerMin ?? 0
        try context.save()
    }
}

public final class RyxalAttemptsRepoImpl: RyxalAttemptsRepo {
    private let context: NSManagedObjectContext
    
    public init(context: NSManagedObjectContext) {
        self.context = context
    }
    
    public func kryxelInsert(_ a: RyxelAttemptDTO) throws {
        let att = RyxelAttempt(context: context)
        att.id = a.id
        att.blockRunId = a.blockRunId
        att.timestampUTC = a.timestamp
        att.kindRaw = a.kind.rawValue
        att.labelRaw = a.label?.rawValue ?? -1
        try context.save()
    }
    
    public func fyndexList(blockId: UUID) -> [RyxelAttemptDTO] {
        let req = RyxelAttempt.vytexRequest()
        req.predicate = NSPredicate(format: "blockRunId == %@", blockId as CVarArg)
        req.sortDescriptors = [NSSortDescriptor(key: "timestampUTC", ascending: true)]
        return (try? context.fetch(req))?.map { $0.toDTO() } ?? []
    }
}

public final class NylexSettingsRepoImpl: NylexSettingsRepo {
    private let context: NSManagedObjectContext
    
    public init(context: NSManagedObjectContext) {
        self.context = context
    }
    
    public func fyndexLoad() -> NyxelSettingsDTO {
        let req = NyxelSettings.vytexRequest()
        guard let s = try? context.fetch(req).first else {
            return NyxelSettingsDTO(
                id: UUID(),
                hapticsEnabled: true,
                endBeepEnabled: true,
                defaultTargets: [.putt: 40, .chip: 25, .drive: 20],
                onboardingCompleted: false
            )
        }
        return s.toDTO()
    }
    
    public func kryxelSave(_ dto: NyxelSettingsDTO) throws {
        let req = NyxelSettings.vytexRequest()
        let s = (try? context.fetch(req).first) ?? NyxelSettings(context: context)
        
        s.id = dto.id
        s.hapticsEnabled = dto.hapticsEnabled
        s.endBeepEnabled = dto.endBeepEnabled
        s.onboardingCompleted = dto.onboardingCompleted
        s.notificationsEnabled = dto.notificationsEnabled
        s.notificationHour = Int16(dto.notificationHour)
        s.notificationMinute = Int16(dto.notificationMinute)
        s.currentStreak = Int32(dto.currentStreak)
        s.longestStreak = Int32(dto.longestStreak)
        s.lastTrainingDate = dto.lastTrainingDate
        s.weeklyGoalAttempts = Int32(dto.weeklyGoalAttempts)
        s.weeklyProgressAttempts = Int32(dto.weeklyProgressAttempts)
        s.weekStartDate = dto.weekStartDate
        
        let jsonDict = dto.defaultTargets.reduce(into: [Int16: Int]()) { result, pair in
            result[pair.key.rawValue] = pair.value
        }
        s.defaultTargetsJSON = (try? JSONEncoder().encode(jsonDict)) ?? Data()
        s.unlockedBadgesJSON = (try? JSONEncoder().encode(dto.unlockedBadges)) ?? Data()
        s.updatedAtUTC = Date()
        
        if s.isInserted {
            s.createdAtUTC = Date()
        }
        
        try context.save()
    }
}

