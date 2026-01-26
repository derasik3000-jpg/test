import Foundation
import CoreData

@objc(TrendCache)
public class TrendCache: NSManagedObject {
    @NSManaged public var id: UUID
    @NSManaged public var windowDays: Int16
    @NSManaged public var lowCount: Int16
    @NSManaged public var midCount: Int16
    @NSManaged public var highCount: Int16
    @NSManaged public var redCount: Int16
    @NSManaged public var updatedAt: Date
}

extension TrendCache {
    @nonobjc public class func requestMaterialization() -> NSFetchRequest<TrendCache> {
        return NSFetchRequest<TrendCache>(entityName: "TrendCache")
    }
}

