import Foundation
import CoreData

extension FizzAppliedLogEntity {
    
    @nonobjc public class func fetchRequest() -> NSFetchRequest<FizzAppliedLogEntity> {
        return NSFetchRequest<FizzAppliedLogEntity>(entityName: "FizzAppliedLogEntity")
    }
    
    @NSManaged public var fizzId: UUID
    @NSManaged public var plinthDate: Date
    @NSManaged public var tarnNote: String?
    @NSManaged public var quirkReplacement: SternReplacementEntity?
    @NSManaged public var quirkVariant: MurkyVariantEntity?
    
}

extension FizzAppliedLogEntity: Identifiable {
    
}

