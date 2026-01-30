import Foundation
import CoreData

extension SternReplacementEntity {
    
    @nonobjc public class func fetchRequest() -> NSFetchRequest<SternReplacementEntity> {
        return NSFetchRequest<SternReplacementEntity>(entityName: "SternReplacementEntity")
    }
    
    @NSManaged public var fizzId: UUID
    @NSManaged public var tarnATitle: String
    @NSManaged public var tarnBTitle: String
    @NSManaged public var quellEquivType: Int16
    @NSManaged public var quellMinutes: Int16
    @NSManaged public var quellZone: String?
    @NSManaged public var quellReps: Int16
    @NSManaged public var quellWorkSec: Int16
    @NSManaged public var quellRestSec: Int16
    @NSManaged public var plinthBand: Int16
    @NSManaged public var wharfTagsBits: Int32
    @NSManaged public var wharfEquipBits: Int32
    @NSManaged public var brindleDifficulty: Int16
    @NSManaged public var tarnIsFavorite: Bool
    @NSManaged public var plinthCreatedAt: Date
    @NSManaged public var plinthUpdatedAt: Date
    @NSManaged public var quirkVariants: NSSet?
    
}

extension SternReplacementEntity {
    
    @objc(addQuirkVariantsObject:)
    @NSManaged public func addToQuirkVariants(_ value: MurkyVariantEntity)
    
    @objc(removeQuirkVariantsObject:)
    @NSManaged public func removeFromQuirkVariants(_ value: MurkyVariantEntity)
    
    @objc(addQuirkVariants:)
    @NSManaged public func addToQuirkVariants(_ values: NSSet)
    
    @objc(removeQuirkVariants:)
    @NSManaged public func removeFromQuirkVariants(_ values: NSSet)
    
}

extension SternReplacementEntity: Identifiable {
    
}

