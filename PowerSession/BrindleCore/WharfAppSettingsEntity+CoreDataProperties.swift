import Foundation
import CoreData

extension WharfAppSettingsEntity {
    
    @nonobjc public class func fetchRequest() -> NSFetchRequest<WharfAppSettingsEntity> {
        return NSFetchRequest<WharfAppSettingsEntity>(entityName: "WharfAppSettingsEntity")
    }
    
    @NSManaged public var fizzId: UUID
    @NSManaged public var wharfSelectedTagsBits: Int32
    @NSManaged public var wharfSelectedEquipBits: Int32
    @NSManaged public var wharfSelectedBandsBits: Int16
    @NSManaged public var tarnHapticsEnabled: Bool
    @NSManaged public var plinthCreatedAt: Date
    @NSManaged public var plinthUpdatedAt: Date
    
}

extension WharfAppSettingsEntity: Identifiable {
    
}

