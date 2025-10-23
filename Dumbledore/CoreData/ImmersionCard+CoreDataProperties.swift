// ImmersionCard+CoreDataProperties.swift
import Foundation
import CoreData

extension ImmersionCard {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<ImmersionCard> {
        return NSFetchRequest<ImmersionCard>(entityName: "ImmersionCard")
    }

    @NSManaged public var id: UUID?
    @NSManaged public var title: String?
    @NSManaged public var topic: String?
    @NSManaged public var phrases: String?
    @NSManaged public var glossary: String?
    @NSManaged public var quiz: String?
    @NSManaged public var createdAt: Date?

}

extension ImmersionCard : Identifiable {

}

// Note: CoreData stores JSON strings for glossary/quiz; decode to DTOs in repos
