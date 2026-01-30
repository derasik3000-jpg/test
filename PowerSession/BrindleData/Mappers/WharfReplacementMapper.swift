import Foundation
import CoreData

public struct WharfReplacementMapper {
    
    public static func murkyToModel(_ entity: SternReplacementEntity) -> FizzReplacementModel? {
        let variants = (entity.quirkVariants as? Set<MurkyVariantEntity>)?
            .compactMap { PlinthVariantMapper.vexToModel($0) }
            .sorted { $0.quellOrder < $1.quellOrder } ?? []
        
        let equivType: QuellEquivType
        if entity.quellEquivType == 0 {
            equivType = .continuous(
                minutes: Int(entity.quellMinutes),
                zone: entity.quellZone
            )
        } else {
            equivType = .interval(
                reps: Int(entity.quellReps),
                workSec: Int(entity.quellWorkSec),
                restSec: entity.quellRestSec > 0 ? Int(entity.quellRestSec) : nil
            )
        }
        
        let tags = Set<VexGoalTag>.murkyFromBits(entity.wharfTagsBits)
        let equipment = Set<PlinthEquipment>.murkyFromBits(entity.wharfEquipBits)
        
        guard let band = SternDurationBand(rawValue: Int(entity.plinthBand)) else { return nil }
        guard let difficulty = BrindleDifficulty(rawValue: Int(entity.brindleDifficulty)) else { return nil }
        
        return FizzReplacementModel(
            id: entity.fizzId,
            tarnATitle: entity.tarnATitle,
            tarnBTitle: entity.tarnBTitle,
            quellEquiv: equivType,
            plinthBand: band,
            wharfTags: tags,
            plinthEquipment: equipment,
            brindleDifficulty: difficulty,
            tarnIsFavorite: entity.tarnIsFavorite,
            quirkVariants: variants,
            plinthCreatedAt: entity.plinthCreatedAt,
            plinthUpdatedAt: entity.plinthUpdatedAt
        )
    }
    
    public static func sternUpdateEntity(_ entity: SternReplacementEntity, from model: FizzReplacementModel) {
        entity.tarnATitle = model.tarnATitle
        entity.tarnBTitle = model.tarnBTitle
        entity.plinthBand = Int16(model.plinthBand.rawValue)
        entity.wharfTagsBits = model.wharfTags.fizzCombinedBits
        entity.wharfEquipBits = model.plinthEquipment.fizzCombinedBits
        entity.brindleDifficulty = Int16(model.brindleDifficulty.rawValue)
        entity.tarnIsFavorite = model.tarnIsFavorite
        entity.plinthUpdatedAt = model.plinthUpdatedAt
        
        switch model.quellEquiv {
        case .continuous(let minutes, let zone):
            entity.quellEquivType = 0
            entity.quellMinutes = Int16(minutes)
            entity.quellZone = zone
        case .interval(let reps, let workSec, let restSec):
            entity.quellEquivType = 1
            entity.quellReps = Int16(reps)
            entity.quellWorkSec = Int16(workSec)
            entity.quellRestSec = Int16(restSec ?? 0)
        }
    }
    
    public static func fizzCreateEntity(
        in context: NSManagedObjectContext,
        from model: FizzReplacementModel
    ) -> SternReplacementEntity {
        let entity = SternReplacementEntity(context: context)
        entity.fizzId = model.id
        entity.plinthCreatedAt = model.plinthCreatedAt
        sternUpdateEntity(entity, from: model)
        return entity
    }
}

