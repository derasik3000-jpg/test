import Foundation
import CoreData
import Combine

final class PersistenceCoordinator {
    static let shared = PersistenceCoordinator()
    
    let container: NSPersistentContainer
    
    private init() {
        container = NSPersistentContainer(name: "PersistenceSchema")
        container.loadPersistentStores { description, error in
            if let error = error {
                fatalError("Core Data failed to load: \(error.localizedDescription)")
            }
        }
        container.viewContext.automaticallyMergesChangesFromParent = true
    }
    
    var context: NSManagedObjectContext {
        container.viewContext
    }
    
    func saveContext() throws {
        if context.hasChanges {
            try context.save()
        }
    }
}

