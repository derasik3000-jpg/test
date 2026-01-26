import Foundation
import CoreData

@objc(Settings)
public class Settings: NSManagedObject {
    @NSManaged public var id: UUID
    @NSManaged public var onboardingShown: Bool
    @NSManaged public var notificationsAllowedCached: Bool
    @NSManaged public var historyRetentionDays: Int16
    @NSManaged public var lastReminderAuditAt: Date?
}

extension Settings {
    @nonobjc public class func requestMaterialization() -> NSFetchRequest<Settings> {
        return NSFetchRequest<Settings>(entityName: "Settings")
    }
    
    func toDTO() -> PreferenceSnapshot {
        PreferenceSnapshot(
            onboardingShown: onboardingShown,
            notificationsAllowedCached: notificationsAllowedCached,
            historyRetentionDays: Int(historyRetentionDays)
        )
    }
    
    func updateFrom(dto: PreferenceSnapshot) {
        self.onboardingShown = dto.onboardingShown
        self.notificationsAllowedCached = dto.notificationsAllowedCached
        self.historyRetentionDays = Int16(dto.historyRetentionDays)
    }
}

