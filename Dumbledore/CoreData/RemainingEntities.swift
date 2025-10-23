// RemainingEntities.swift
import Foundation
import CoreData

// MARK: - MicroLesson
@objc(MicroLesson)
public class MicroLesson: NSManagedObject {
    @nonobjc public class func fetchRequest() -> NSFetchRequest<MicroLesson> {
        return NSFetchRequest<MicroLesson>(entityName: "MicroLesson")
    }

    @NSManaged public var id: UUID?
    @NSManaged public var kind: Int16
    @NSManaged public var items: String?
    @NSManaged public var estimatedSec: Int16
    @NSManaged public var createdFrom: String?
    @NSManaged public var dayKey: Date?
}

extension MicroLesson : Identifiable {}

// MARK: - WeakSpot
@objc(WeakSpot)
public class WeakSpot: NSManagedObject {
    @nonobjc public class func fetchRequest() -> NSFetchRequest<WeakSpot> {
        return NSFetchRequest<WeakSpot>(entityName: "WeakSpot")
    }

    @NSManaged public var id: UUID?
    @NSManaged public var type: Int16
    @NSManaged public var key: String?
    @NSManaged public var count7d: Int16
    @NSManaged public var lastSeenAt: Date?
    @NSManaged public var autoQueued: Bool
}

extension WeakSpot : Identifiable {}

// MARK: - DailyProgress
@objc(DailyProgress)
public class DailyProgress: NSManagedObject {
    @nonobjc public class func fetchRequest() -> NSFetchRequest<DailyProgress> {
        return NSFetchRequest<DailyProgress>(entityName: "DailyProgress")
    }

    @NSManaged public var dayKey: Date?
    @NSManaged public var usefulMinutes: Int16
    @NSManaged public var dialogMinutes: Int16
    @NSManaged public var immersionMinutes: Int16
    @NSManaged public var microLessonsDone: Int16
    @NSManaged public var goalsCompleted: Int16
    @NSManaged public var newWordsCount: Int16
}

extension DailyProgress : Identifiable {}

// MARK: - Settings
@objc(Settings)
public class Settings: NSManagedObject {
    @nonobjc public class func fetchRequest() -> NSFetchRequest<Settings> {
        return NSFetchRequest<Settings>(entityName: "Settings")
    }

    @NSManaged public var id: UUID?
    @NSManaged public var level: Int16
    @NSManaged public var ttsRate: Double
    @NSManaged public var autoHints: Bool
    @NSManaged public var storeTranscripts: Bool
    @NSManaged public var quietHours: String?
    @NSManaged public var dailyPromptLimit: Int16
    @NSManaged public var rolloverHour: Int16
}

extension Settings : Identifiable {}

// MARK: - InterestTopic
@objc(InterestTopic)
public class InterestTopic: NSManagedObject {
    @nonobjc public class func fetchRequest() -> NSFetchRequest<InterestTopic> {
        return NSFetchRequest<InterestTopic>(entityName: "InterestTopic")
    }

    @NSManaged public var id: UUID?
    @NSManaged public var tag: String?
    @NSManaged public var enabled: Bool
}

extension InterestTopic : Identifiable {}

// MARK: - PronunciationEvent
@objc(PronunciationEvent)
public class PronunciationEvent: NSManagedObject {
    @nonobjc public class func fetchRequest() -> NSFetchRequest<PronunciationEvent> {
        return NSFetchRequest<PronunciationEvent>(entityName: "PronunciationEvent")
    }

    @NSManaged public var id: UUID?
    @NSManaged public var turnTs: Date?
    @NSManaged public var word: String?
    @NSManaged public var status: Int16
    @NSManaged public var sessionId: UUID?
}

extension PronunciationEvent : Identifiable {}
