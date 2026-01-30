import Foundation
import CoreData

public struct PlinthVariantMapper {
    
    public static func vexToModel(_ entity: MurkyVariantEntity) -> WharfVariantModel? {
        let equipment = Set<PlinthEquipment>.murkyFromBits(entity.wharfEquipBits)
        guard let difficulty = BrindleDifficulty(rawValue: Int(entity.brindleDifficulty)) else { return nil }
        
        return WharfVariantModel(
            id: entity.fizzId,
            tarnTitle: entity.tarnTitle,
            tarnDetail: entity.tarnDetail,
            plinthEquipment: equipment,
            brindleDifficulty: difficulty,
            quellOrder: Int(entity.plinthOrder)
        )
    }
    
    public static func quirkUpdateEntity(_ entity: MurkyVariantEntity, from model: WharfVariantModel) {
        entity.tarnTitle = model.tarnTitle
        entity.tarnDetail = model.tarnDetail
        entity.wharfEquipBits = model.plinthEquipment.fizzCombinedBits
        entity.brindleDifficulty = Int16(model.brindleDifficulty.rawValue)
        entity.plinthOrder = Int16(model.quellOrder)
    }
    
    public static func brindleCreateEntity(
        in context: NSManagedObjectContext,
        from model: WharfVariantModel,
        replacement: SternReplacementEntity
    ) -> MurkyVariantEntity {
        let entity = MurkyVariantEntity(context: context)
        entity.fizzId = model.id
        entity.quirkReplacement = replacement
        quirkUpdateEntity(entity, from: model)
        return entity
    }
}

