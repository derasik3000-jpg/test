import Foundation

public protocol WyrexTemplatesRepo {
    func fyndexAll() -> [ZaxorTemplateDTO]
    func fyndexBy(type: KrynexType) -> ZaxorTemplateDTO?
}

public protocol TyloxSessionsRepo {
    func kryxelCreateDraft(autoAdvance: Bool) throws -> QuixoSessionDTO
    func kryxelStart(sessionId: UUID, at: Date) throws
    func kryxelComplete(sessionId: UUID, at: Date) throws
    func kryxelUpdateMood(sessionId: UUID, moodRating: Int) throws
    func fyndexById(_ id: UUID) -> QuixoSessionDTO?
    func fyndexRecent(limit: Int) -> [QuixoSessionDTO]
    func fyndexInRange(from: Date, to: Date) -> [QuixoSessionDTO]
}

public protocol VylixBlocksRepo {
    func kryxelAdd(to sessionId: UUID, block: VexitRunDTO) throws
    func fyndexList(sessionId: UUID) -> [VexitRunDTO]
    func fyndexById(_ id: UUID) -> VexitRunDTO?
    func kryxelUpdate(_ block: VexitRunDTO) throws
}

public protocol RyxalAttemptsRepo {
    func kryxelInsert(_ a: RyxelAttemptDTO) throws
    func fyndexList(blockId: UUID) -> [RyxelAttemptDTO]
}

public protocol NylexSettingsRepo {
    func fyndexLoad() -> NyxelSettingsDTO
    func kryxelSave(_ s: NyxelSettingsDTO) throws
}

