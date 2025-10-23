// DialogNode+CoreDataProperties.swift
import Foundation
import CoreData

extension DialogNode {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<DialogNode> {
        return NSFetchRequest<DialogNode>(entityName: "DialogNode")
    }

    @NSManaged public var id: UUID?
    @NSManaged public var scenarioId: UUID?
    @NSManaged public var type: Int16
    @NSManaged public var levelVariant: Int16
    @NSManaged public var payload: String?
    @NSManaged public var expectedIntents: String?
    @NSManaged public var transitions: String?
    @NSManaged public var isStart: Bool
    @NSManaged public var isTerminal: Bool

}

extension DialogNode : Identifiable {

}
