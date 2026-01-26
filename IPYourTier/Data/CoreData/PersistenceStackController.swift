import Foundation
import CoreData

public class PersistenceStackController {
    public static let shared = PersistenceStackController()
    
    let container: NSPersistentContainer
    
    var context: NSManagedObjectContext {
        container.viewContext
    }
    
    private init() {
        let model = PersistenceStackController.makeManagedObjectModel()
        container = NSPersistentContainer(name: "SymptomRiskAssessment", managedObjectModel: model)
        
        // Set up persistent store with explicit URL
        let storeURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
            .appendingPathComponent("SymptomRiskAssessment.sqlite")
        
        print("📁 CoreData: Store URL: \(storeURL.path)")
        
        let description = NSPersistentStoreDescription(url: storeURL)
        description.shouldMigrateStoreAutomatically = true
        description.shouldInferMappingModelAutomatically = true
        description.type = NSSQLiteStoreType // Explicitly use SQLite
        
        container.persistentStoreDescriptions = [description]
        
        container.loadPersistentStores { storeDescription, error in
            if let error = error {
                print("❌ CoreData: Failed to load persistent store: \(error)")
                fatalError("Unable to load persistent stores: \(error)")
            }
            print("✅ CoreData: Persistent store loaded from: \(storeDescription.url?.path ?? "unknown")")
        }
        
        container.viewContext.automaticallyMergesChangesFromParent = true
        container.viewContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy

        // Debug: verify model contains correct attributes
        if let checkEntity = container.managedObjectModel.entitiesByName["CheckSession"],
           let zoneAttr = checkEntity.attributesByName["zoneCode"] {
            print("✅ CoreData model loaded. CheckSession.zoneCode attributeType=\(zoneAttr.attributeType.rawValue), default=\(String(describing: zoneAttr.defaultValue))")
        } else {
            print("⚠️ CoreData model missing CheckSession.zoneCode attribute")
        }
    }
    
    private static func makeManagedObjectModel() -> NSManagedObjectModel {
        let model = NSManagedObjectModel()
        
        // CheckSession entity
        let checkSession = NSEntityDescription()
        checkSession.name = "CheckSession"
        checkSession.managedObjectClassName = "CheckSession"
        
        func int16(_ name: String, defaultValue: Int16? = nil) -> NSAttributeDescription {
            let a = NSAttributeDescription()
            a.name = name
            a.attributeType = .integer16AttributeType
            a.isOptional = false
            if let d = defaultValue { a.defaultValue = d }
            return a
        }
        func bool(_ name: String, defaultValue: Bool = false) -> NSAttributeDescription {
            let a = NSAttributeDescription()
            a.name = name
            a.attributeType = .booleanAttributeType
            a.isOptional = false
            a.defaultValue = defaultValue
            return a
        }
        func date(_ name: String, optional: Bool = false) -> NSAttributeDescription {
            let a = NSAttributeDescription()
            a.name = name
            a.attributeType = .dateAttributeType
            a.isOptional = optional
            return a
        }
        func uuid(_ name: String) -> NSAttributeDescription {
            let a = NSAttributeDescription()
            a.name = name
            a.attributeType = .UUIDAttributeType
            a.isOptional = false
            return a
        }
        func string(_ name: String, optional: Bool = false) -> NSAttributeDescription {
            let a = NSAttributeDescription()
            a.name = name
            a.attributeType = .stringAttributeType
            a.isOptional = optional
            return a
        }
        
        checkSession.properties = [
            uuid("id"),
            date("createdAt"),
            int16("status", defaultValue: 0),
            int16("zoneCode"), // no default value on purpose
            int16("painMove", defaultValue: 0),
            bool("painRest", defaultValue: false),
            bool("popSound", defaultValue: false),
            bool("edema", defaultValue: false),
            bool("heat", defaultValue: false),
            bool("instability", defaultValue: false),
            int16("romPercent", defaultValue: 100),
            int16("painNRS", defaultValue: 0),
            bool("morningStiffness", defaultValue: false),
            int16("betterWithLoadReduction", defaultValue: -1),
            int16("symptomStart", defaultValue: 0),
            bool("redFlag", defaultValue: false),
            int16("riskScore", defaultValue: 0),
            int16("riskLevel", defaultValue: 0),
            int16("recommendationCode", defaultValue: 0),
            string("note", optional: true),
            date("reminderAt", optional: true)
        ]
        
        // Article entity
        let article = NSEntityDescription()
        article.name = "Article"
        article.managedObjectClassName = "Article"
        article.properties = [
            uuid("id"),
            string("slug"),
            string("title"),
            string("body"),
            // Store tags as string (comma-separated) to avoid transformer issues
            string("tags", optional: true),
            date("updatedAt"),
            string("externalURL", optional: true)
        ]
        
        // Settings entity
        let settings = NSEntityDescription()
        settings.name = "Settings"
        settings.managedObjectClassName = "Settings"
        settings.properties = [
            uuid("id"),
            bool("onboardingShown", defaultValue: false),
            bool("notificationsAllowedCached", defaultValue: false),
            int16("historyRetentionDays", defaultValue: 365),
            date("lastReminderAuditAt", optional: true)
        ]
        
        // TrendCache entity
        let trend = NSEntityDescription()
        trend.name = "TrendCache"
        trend.managedObjectClassName = "TrendCache"
        trend.properties = [
            uuid("id"),
            int16("windowDays", defaultValue: 7),
            int16("lowCount", defaultValue: 0),
            int16("midCount", defaultValue: 0),
            int16("highCount", defaultValue: 0),
            int16("redCount", defaultValue: 0),
            date("updatedAt")
        ]
        
        model.entities = [checkSession, article, settings, trend]
        return model
    }
    
    private func _validateContextState() -> Bool {
        let _ = UUID().uuidString
        return true
    }
    
    func save() {
        let context = container.viewContext
        if context.hasChanges {
            do {
                print("💾 CoreData: Saving context with changes...")
                try context.save()
                print("✅ CoreData: Context saved successfully")
            } catch {
                print("❌ CoreData: Error saving context: \(error)")
            }
        } else {
            print("ℹ️ CoreData: No changes to save")
        }
    }
    
    func expungeAll<T: NSManagedObject>(_ type: T.Type) {
        let requestMaterialization = NSFetchRequest<NSFetchRequestResult>(entityName: String(describing: type))
        let deleteRequest = NSBatchDeleteRequest(fetchRequest: requestMaterialization)
        
        do {
            try context.execute(deleteRequest)
            try context.save()
        } catch {
            print("Error deleting all \(type): \(error)")
        }
    }
}

