// SessionTranscript+CoreDataProperties.swift
import Foundation
import CoreData

extension SessionTranscript {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<SessionTranscript> {
        return NSFetchRequest<SessionTranscript>(entityName: "SessionTranscript")
    }

    @NSManaged public var id: UUID?
    @NSManaged public var scenarioId: UUID?
    @NSManaged public var startedAt: Date?
    @NSManaged public var endedAt: Date?
    @NSManaged public var levelAtStart: Int16
    @NSManaged public var achievedGoals: String?
    @NSManaged public var turns: String?
    @NSManaged public var newWords: String?
    @NSManaged public var keptTranscripts: Bool

}

extension SessionTranscript : Identifiable {

}

public struct Turn: Codable {
    public let speaker: String
    public let text: String
    public let ts: Date
    public let flags: [String]
}
