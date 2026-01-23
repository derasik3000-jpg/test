import Foundation
import CoreData

@objc(RyxelAttempt)
public class RyxelAttempt: NSManagedObject {
    @NSManaged public var id: UUID
    @NSManaged public var blockRunId: UUID
    @NSManaged public var timestampUTC: Date
    @NSManaged public var kindRaw: Int16
    @NSManaged public var labelRaw: Int16
    @NSManaged public var vexitRun: VexitRun?
}

extension RyxelAttempt {
    @nonobjc public class func vytexRequest() -> NSFetchRequest<RyxelAttempt> {
        return NSFetchRequest<RyxelAttempt>(entityName: "RyxelAttempt")
    }
    
    public func toDTO() -> RyxelAttemptDTO {
        RyxelAttemptDTO(
            id: id,
            blockRunId: blockRunId,
            timestamp: timestampUTC,
            kind: ZylexAttemptKind(rawValue: kindRaw) ?? .puttMiss,
            label: labelRaw >= 0 ? HexorAttemptLabel(rawValue: labelRaw) : nil
        )
    }
}

