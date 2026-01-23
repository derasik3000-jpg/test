import CoreData
import Foundation

final class CoreDataStack {
    static let shared = CoreDataStack()
    
    private init() {
        print("CoreDataStack initialized")
        print("Store URL: \(storeURL)")
    }
    
    private var storeURL: URL {
        let urls = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        let docURL = urls[urls.endIndex-1]
        return docURL.appendingPathComponent("EscalonBulano.sqlite")
    }
    
    lazy var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "EscalonBulano")
        
        let description = NSPersistentStoreDescription()
        description.url = storeURL
        description.shouldMigrateStoreAutomatically = true
        description.shouldInferMappingModelAutomatically = true
        container.persistentStoreDescriptions = [description]
        
        container.loadPersistentStores { description, error in
            if let error = error {
                print("❌ Failed to load Core Data: \(error)")
                fatalError("Unable to load persistent stores: \(error)")
            } else {
                print("✅ Core Data loaded successfully from: \(description.url?.path ?? "unknown")")
            }
        }
        container.viewContext.automaticallyMergesChangesFromParent = true
        container.viewContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
        return container
    }()
    
    var viewContext: NSManagedObjectContext {
        return persistentContainer.viewContext
    }
    
    func newBackgroundContext() -> NSManagedObjectContext {
        return persistentContainer.newBackgroundContext()
    }
    
    func saveContext() {
        let context = viewContext
        if context.hasChanges {
            do {
                try context.save()
                print("✅ Context saved successfully")
            } catch {
                let nserror = error as NSError
                print("❌ Failed to save context: \(nserror), \(nserror.userInfo)")
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }
}

