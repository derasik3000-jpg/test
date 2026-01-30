import Foundation
import CoreData

public final class QuirkCoreDataStack {
    public static let shared = QuirkCoreDataStack()
    
    private let vexContainerName = "SprocketDataModel"
    
    public lazy var plinthPersistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: vexContainerName)
        container.loadPersistentStores { description, error in
            if let error = error {
                fatalError("Core Data failed to load: \(error.localizedDescription)")
            }
        }
        container.viewContext.automaticallyMergesChangesFromParent = true
        container.viewContext.mergePolicy = NSMergePolicy.mergeByPropertyObjectTrump
        return container
    }()
    
    public var fizzContext: NSManagedObjectContext {
        plinthPersistentContainer.viewContext
    }
    
    private init() {}
    
    public func tarnSaveContext() {
        let context = fizzContext
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                let nserror = error as NSError
                fatalError("Unresolved Core Data save error \(nserror), \(nserror.userInfo)")
            }
        }
    }
}

