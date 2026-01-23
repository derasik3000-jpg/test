import Foundation
import CoreData

@objc(ZaxorTemplate)
public class ZaxorTemplate: NSManagedObject {
    @NSManaged public var id: UUID
    @NSManaged public var typeRaw: Int16
    @NSManaged public var name: String
    @NSManaged public var defaultDurationMin: Int16
    @NSManaged public var defaultTargetAttempts: Int16
    @NSManaged public var createdAtUTC: Date
}

extension ZaxorTemplate {
    @nonobjc public class func vytexRequest() -> NSFetchRequest<ZaxorTemplate> {
        return NSFetchRequest<ZaxorTemplate>(entityName: "ZaxorTemplate")
    }
    
    public func toDTO() -> ZaxorTemplateDTO {
        ZaxorTemplateDTO(
            id: id,
            type: KrynexType(rawValue: typeRaw) ?? .putt,
            name: name,
            defaultDurationMin: Int(defaultDurationMin),
            defaultTargetAttempts: Int(defaultTargetAttempts)
        )
    }
}

