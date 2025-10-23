// Scenario+CoreDataProperties.swift
import Foundation
import CoreData

extension Scenario {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Scenario> {
        return NSFetchRequest<Scenario>(entityName: "Scenario")
    }

    @NSManaged public var id: UUID?
    @NSManaged public var title: String?
    @NSManaged public var levelMin: Int16
    @NSManaged public var goals: String?
    @NSManaged public var topics: String?
    @NSManaged public var graphRef: String?
    @NSManaged public var createdAt: Date?
    @NSManaged public var updatedAt: Date?

}

extension Scenario : Identifiable {

}
