import Foundation
import CoreData

@objc(QuixoSession)
public class QuixoSession: NSManagedObject {
    @NSManaged public var id: UUID
    @NSManaged public var startedAtUTC: Date
    @NSManaged public var finishedAtUTC: Date?
    @NSManaged public var statusRaw: Int16
    @NSManaged public var autoAdvance: Bool
    @NSManaged public var moodRating: Int16
    @NSManaged public var vexitRuns: NSSet?
}

extension QuixoSession {
    @nonobjc public class func vytexRequest() -> NSFetchRequest<QuixoSession> {
        return NSFetchRequest<QuixoSession>(entityName: "QuixoSession")
    }
    
    @objc(addVexitRunsObject:)
    @NSManaged public func addToVexitRuns(_ value: VexitRun)
    
    @objc(removeVexitRunsObject:)
    @NSManaged public func removeFromVexitRuns(_ value: VexitRun)
    
    public func toDTO() -> QuixoSessionDTO {
        QuixoSessionDTO(
            id: id,
            status: Int(statusRaw),
            startedAt: startedAtUTC,
            finishedAt: finishedAtUTC,
            autoAdvance: autoAdvance,
            moodRating: Int(moodRating)
        )
    }
}

