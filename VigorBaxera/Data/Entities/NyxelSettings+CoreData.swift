import Foundation
import CoreData

@objc(NyxelSettings)
public class NyxelSettings: NSManagedObject {
    @NSManaged public var id: UUID
    @NSManaged public var hapticsEnabled: Bool
    @NSManaged public var endBeepEnabled: Bool
    @NSManaged public var defaultTargetsJSON: Data
    @NSManaged public var onboardingCompleted: Bool
    @NSManaged public var notificationsEnabled: Bool
    @NSManaged public var notificationHour: Int16
    @NSManaged public var notificationMinute: Int16
    @NSManaged public var currentStreak: Int32
    @NSManaged public var longestStreak: Int32
    @NSManaged public var lastTrainingDate: Date?
    @NSManaged public var weeklyGoalAttempts: Int32
    @NSManaged public var weeklyProgressAttempts: Int32
    @NSManaged public var weekStartDate: Date?
    @NSManaged public var unlockedBadgesJSON: Data?
    @NSManaged public var createdAtUTC: Date
    @NSManaged public var updatedAtUTC: Date
}

extension NyxelSettings {
    @nonobjc public class func vytexRequest() -> NSFetchRequest<NyxelSettings> {
        return NSFetchRequest<NyxelSettings>(entityName: "NyxelSettings")
    }
    
    public func toDTO() -> NyxelSettingsDTO {
        let targets = (try? JSONDecoder().decode([Int16: Int].self, from: defaultTargetsJSON))
            .map { dict in
                dict.reduce(into: [KrynexType: Int]()) { result, pair in
                    if let type = KrynexType(rawValue: pair.key) {
                        result[type] = pair.value
                    }
                }
            } ?? [:]
        
        let badges: Set<String> = (try? JSONDecoder().decode(Set<String>.self, from: unlockedBadgesJSON ?? Data())) ?? []
        
        return NyxelSettingsDTO(
            id: id,
            hapticsEnabled: hapticsEnabled,
            endBeepEnabled: endBeepEnabled,
            defaultTargets: targets,
            onboardingCompleted: onboardingCompleted,
            notificationsEnabled: notificationsEnabled,
            notificationHour: Int(notificationHour),
            notificationMinute: Int(notificationMinute),
            currentStreak: Int(currentStreak),
            longestStreak: Int(longestStreak),
            lastTrainingDate: lastTrainingDate,
            weeklyGoalAttempts: Int(weeklyGoalAttempts),
            weeklyProgressAttempts: Int(weeklyProgressAttempts),
            weekStartDate: weekStartDate,
            unlockedBadges: badges
        )
    }
}

