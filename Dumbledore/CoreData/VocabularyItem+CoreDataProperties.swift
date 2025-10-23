// VocabularyItem+CoreDataProperties.swift
import Foundation
import CoreData

extension VocabularyItem {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<VocabularyItem> {
        return NSFetchRequest<VocabularyItem>(entityName: "VocabularyItem")
    }

    @NSManaged public var id: UUID?
    @NSManaged public var text: String?
    @NSManaged public var translation: String?
    @NSManaged public var examples: String?
    @NSManaged public var topicTags: String?
    @NSManaged public var addedAt: Date?
    @NSManaged public var strength: Int16

}

extension VocabularyItem : Identifiable {

}
