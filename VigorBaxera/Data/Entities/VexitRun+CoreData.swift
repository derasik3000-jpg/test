import Foundation
import CoreData

@objc(VexitRun)
public class VexitRun: NSManagedObject {
    @NSManaged public var id: UUID
    @NSManaged public var sessionId: UUID
    @NSManaged public var orderIndex: Int16
    @NSManaged public var typeRaw: Int16
    @NSManaged public var durationMin: Int16
    @NSManaged public var targetAttempts: Int16
    @NSManaged public var startedAtUTC: Date?
    @NSManaged public var finishedAtUTC: Date?
    @NSManaged public var actualDurationSec: Int32
    @NSManaged public var attemptsTotal: Int32
    @NSManaged public var successCount: Int32
    @NSManaged public var conversionPct: Double
    @NSManaged public var pacePerMin: Double
    @NSManaged public var quixoSession: QuixoSession?
    @NSManaged public var ryxelAttempts: NSSet?
}

extension VexitRun {
    @nonobjc public class func vytexRequest() -> NSFetchRequest<VexitRun> {
        return NSFetchRequest<VexitRun>(entityName: "VexitRun")
    }
    
    @objc(addRyxelAttemptsObject:)
    @NSManaged public func addToRyxelAttempts(_ value: RyxelAttempt)
    
    @objc(removeRyxelAttemptsObject:)
    @NSManaged public func removeFromRyxelAttempts(_ value: RyxelAttempt)
    
    public func toDTO() -> VexitRunDTO {
        VexitRunDTO(
            id: id,
            sessionId: sessionId,
            orderIndex: Int(orderIndex),
            type: KrynexType(rawValue: typeRaw) ?? .putt,
            durationMin: Int(durationMin),
            targetAttempts: Int(targetAttempts),
            startedAt: startedAtUTC,
            finishedAt: finishedAtUTC,
            actualDurationSec: Int(actualDurationSec),
            attemptsTotal: Int(attemptsTotal),
            successCount: Int(successCount),
            conversionPct: attemptsTotal > 0 ? conversionPct : nil,
            pacePerMin: attemptsTotal > 0 ? pacePerMin : nil
        )
    }
}

