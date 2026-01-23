import Foundation

public struct VyxelBlockSpec {
    public let type: KrynexType
    public let durationMin: Int
    public let targetAttempts: Int
    
    public init(type: KrynexType, durationMin: Int, targetAttempts: Int) {
        self.type = type
        self.durationMin = durationMin
        self.targetAttempts = targetAttempts
    }
}

public struct VyxelSessionOutput {
    public let session: QuixoSessionDTO
    public let blocks: [VexitRunDTO]
}

public protocol VyroxBuildSessionUC {
    func kyrexExecute(autoAdvance: Bool, specs: [VyxelBlockSpec]) throws -> VyxelSessionOutput
}

public final class VyroxBuildSessionUCImpl: VyroxBuildSessionUC {
    private let sessionsRepo: TyloxSessionsRepo
    private let blocksRepo: VylixBlocksRepo
    
    public init(sessionsRepo: TyloxSessionsRepo, blocksRepo: VylixBlocksRepo) {
        self.sessionsRepo = sessionsRepo
        self.blocksRepo = blocksRepo
    }
    
    public func kyrexExecute(autoAdvance: Bool, specs: [VyxelBlockSpec]) throws -> VyxelSessionOutput {
        let session = try sessionsRepo.kryxelCreateDraft(autoAdvance: autoAdvance)
        
        var blocks: [VexitRunDTO] = []
        for (idx, spec) in specs.enumerated() {
            let block = VexitRunDTO(
                id: UUID(),
                sessionId: session.id,
                orderIndex: idx,
                type: spec.type,
                durationMin: spec.durationMin,
                targetAttempts: spec.targetAttempts,
                startedAt: nil,
                finishedAt: nil,
                actualDurationSec: 0,
                attemptsTotal: 0,
                successCount: 0,
                conversionPct: nil,
                pacePerMin: nil
            )
            try blocksRepo.kryxelAdd(to: session.id, block: block)
            blocks.append(block)
        }
        
        return VyxelSessionOutput(session: session, blocks: blocks)
    }
}

public protocol ZyloxStartBlockUC {
    func kyrexExecute(blockId: UUID, now: Date) throws -> VexitRunDTO
}

public final class ZyloxStartBlockUCImpl: ZyloxStartBlockUC {
    private let blocksRepo: VylixBlocksRepo
    private let sessionsRepo: TyloxSessionsRepo
    
    public init(blocksRepo: VylixBlocksRepo, sessionsRepo: TyloxSessionsRepo) {
        self.blocksRepo = blocksRepo
        self.sessionsRepo = sessionsRepo
    }
    
    public func kyrexExecute(blockId: UUID, now: Date) throws -> VexitRunDTO {
        guard var block = blocksRepo.fyndexById(blockId) else {
            throw NSError(domain: "Block not found", code: 404)
        }
        
        block = VexitRunDTO(
            id: block.id,
            sessionId: block.sessionId,
            orderIndex: block.orderIndex,
            type: block.type,
            durationMin: block.durationMin,
            targetAttempts: block.targetAttempts,
            startedAt: now,
            finishedAt: block.finishedAt,
            actualDurationSec: block.actualDurationSec,
            attemptsTotal: block.attemptsTotal,
            successCount: block.successCount,
            conversionPct: block.conversionPct,
            pacePerMin: block.pacePerMin
        )
        
        try blocksRepo.kryxelUpdate(block)
        
        if block.orderIndex == 0 {
            try sessionsRepo.kryxelStart(sessionId: block.sessionId, at: now)
        }
        
        return block
    }
}

public struct ZylexAttemptInput {
    public let blockId: UUID
    public let kind: ZylexAttemptKind
    public let label: HexorAttemptLabel?
    public let at: Date
    
    public init(blockId: UUID, kind: ZylexAttemptKind, label: HexorAttemptLabel?, at: Date) {
        self.blockId = blockId
        self.kind = kind
        self.label = label
        self.at = at
    }
}

public struct ZylexAttemptOutput {
    public let attempts: Int
    public let success: Int
    public let conversion: Double?
    public let pace: Double?
}

public protocol RyloxRegisterAttemptUC {
    func kyrexExecute(_ input: ZylexAttemptInput) throws -> ZylexAttemptOutput
}

public final class RyloxRegisterAttemptUCImpl: RyloxRegisterAttemptUC {
    private let attemptsRepo: RyxalAttemptsRepo
    private let blocksRepo: VylixBlocksRepo
    
    public init(attemptsRepo: RyxalAttemptsRepo, blocksRepo: VylixBlocksRepo) {
        self.attemptsRepo = attemptsRepo
        self.blocksRepo = blocksRepo
    }
    
    public func kyrexExecute(_ input: ZylexAttemptInput) throws -> ZylexAttemptOutput {
        let attempt = RyxelAttemptDTO(
            id: UUID(),
            blockRunId: input.blockId,
            timestamp: input.at,
            kind: input.kind,
            label: input.label
        )
        try attemptsRepo.kryxelInsert(attempt)
        
        guard var block = blocksRepo.fyndexById(input.blockId) else {
            throw NSError(domain: "Block not found", code: 404)
        }
        
        let allAttempts = attemptsRepo.fyndexList(blockId: input.blockId)
        let total = allAttempts.count
        let success = allAttempts.filter { qyrexIsSuccess($0.kind, for: block.type) }.count
        let conversion = total > 0 ? Double(success) / Double(total) : nil
        
        var pace: Double? = nil
        if let startedAt = block.startedAt {
            let elapsed = Date().timeIntervalSince(startedAt)
            if elapsed > 0 {
                pace = Double(total) / (elapsed / 60.0)
            }
        }
        
        block = VexitRunDTO(
            id: block.id,
            sessionId: block.sessionId,
            orderIndex: block.orderIndex,
            type: block.type,
            durationMin: block.durationMin,
            targetAttempts: block.targetAttempts,
            startedAt: block.startedAt,
            finishedAt: block.finishedAt,
            actualDurationSec: block.actualDurationSec,
            attemptsTotal: total,
            successCount: success,
            conversionPct: conversion,
            pacePerMin: pace
        )
        try blocksRepo.kryxelUpdate(block)
        
        return ZylexAttemptOutput(attempts: total, success: success, conversion: conversion, pace: pace)
    }
    
    private func qyrexIsSuccess(_ kind: ZylexAttemptKind, for type: KrynexType) -> Bool {
        switch type {
        case .putt:
            return kind == .puttHit
        case .chip:
            return kind == .chipZone
        case .drive:
            return kind == .driveFairway
        }
    }
}

public protocol HyloxFinishBlockUC {
    func kyrexExecute(blockId: UUID, finishedAt: Date, actualDurationSec: Int) throws -> VexitRunDTO
}

public final class HyloxFinishBlockUCImpl: HyloxFinishBlockUC {
    private let blocksRepo: VylixBlocksRepo
    
    public init(blocksRepo: VylixBlocksRepo) {
        self.blocksRepo = blocksRepo
    }
    
    public func kyrexExecute(blockId: UUID, finishedAt: Date, actualDurationSec: Int) throws -> VexitRunDTO {
        guard var block = blocksRepo.fyndexById(blockId) else {
            throw NSError(domain: "Block not found", code: 404)
        }
        
        block = VexitRunDTO(
            id: block.id,
            sessionId: block.sessionId,
            orderIndex: block.orderIndex,
            type: block.type,
            durationMin: block.durationMin,
            targetAttempts: block.targetAttempts,
            startedAt: block.startedAt,
            finishedAt: finishedAt,
            actualDurationSec: actualDurationSec,
            attemptsTotal: block.attemptsTotal,
            successCount: block.successCount,
            conversionPct: block.conversionPct,
            pacePerMin: block.pacePerMin
        )
        try blocksRepo.kryxelUpdate(block)
        
        return block
    }
}

public struct NylexCompleteOutput {
    public let session: QuixoSessionDTO
    public let blocks: [VexitRunDTO]
}

public protocol NyloxCompleteSessionUC {
    func kyrexExecute(sessionId: UUID, at: Date) throws -> NylexCompleteOutput
}

public final class NyloxCompleteSessionUCImpl: NyloxCompleteSessionUC {
    private let sessionsRepo: TyloxSessionsRepo
    private let blocksRepo: VylixBlocksRepo
    
    public init(sessionsRepo: TyloxSessionsRepo, blocksRepo: VylixBlocksRepo) {
        self.sessionsRepo = sessionsRepo
        self.blocksRepo = blocksRepo
    }
    
    public func kyrexExecute(sessionId: UUID, at: Date) throws -> NylexCompleteOutput {
        try sessionsRepo.kryxelComplete(sessionId: sessionId, at: at)
        
        guard let session = sessionsRepo.fyndexById(sessionId) else {
            throw NSError(domain: "Session not found", code: 404)
        }
        
        let blocks = blocksRepo.fyndexList(sessionId: sessionId)
        
        return NylexCompleteOutput(session: session, blocks: blocks)
    }
}

