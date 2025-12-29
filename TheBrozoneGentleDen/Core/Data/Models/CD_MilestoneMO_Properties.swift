import Foundation
import CoreData

extension AchievementRecord {
    
    @nonobjc public class func fetchRequest() -> NSFetchRequest<AchievementRecord> {
        return NSFetchRequest<AchievementRecord>(entityName: "MilestoneEntity")
    }
    
    @NSManaged public var zephyrId: UUID?
    @NSManaged public var epicTitleText: String?
    @NSManaged public var chronicleNoteContent: String?
    @NSManaged public var temporalAchievementDate: Date?
    @NSManaged public var connectedEntryReference: UUID?
    @NSManaged public var cosmicSphereAnchor: CategoryRecord?
}

extension AchievementRecord: Identifiable {
    
}

