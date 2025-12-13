import CoreData
import Foundation

class GamingDataContainer {
    static let shared = GamingDataContainer()
    
    lazy var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "GamingCoreModel")
        container.loadPersistentStores { _, error in
            if let error = error as NSError? {
                fatalError("CoreData load error: \(error), \(error.userInfo)")
            }
        }
        container.viewContext.automaticallyMergesChangesFromParent = true
        return container
    }()
    
    var context: NSManagedObjectContext {
        persistentContainer.viewContext
    }
    
    func saveContext() {
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                let nsError = error as NSError
                fatalError("CoreData save error: \(nsError), \(nsError.userInfo)")
            }
        }
    }
}

