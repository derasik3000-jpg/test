import Foundation
import CoreData

extension MurkyVariantEntity {
    
    @nonobjc public class func fetchRequest() -> NSFetchRequest<MurkyVariantEntity> {
        return NSFetchRequest<MurkyVariantEntity>(entityName: "MurkyVariantEntity")
    }
    
    @NSManaged public var fizzId: UUID
    @NSManaged public var tarnTitle: String
    @NSManaged public var tarnDetail: String?
    @NSManaged public var wharfEquipBits: Int32
    @NSManaged public var brindleDifficulty: Int16
    @NSManaged public var plinthOrder: Int16
    @NSManaged public var quirkReplacement: SternReplacementEntity?
    
}

extension MurkyVariantEntity: Identifiable {
    
}

