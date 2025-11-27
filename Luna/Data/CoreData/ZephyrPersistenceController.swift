import CoreData

class ZephyrPersistenceController {
    static let nebula = ZephyrPersistenceController()
    
    let cosmosContainer: NSPersistentContainer
    
    init(inMemory: Bool = false) {
        cosmosContainer = NSPersistentContainer(name: "ZephyrDataModel")
        
        if inMemory {
            cosmosContainer.persistentStoreDescriptions.first?.url = URL(fileURLWithPath: "/dev/null")
        }
        
        cosmosContainer.loadPersistentStores { description, error in
            if let error = error {
                fatalError("Failed to load cosmos: \(error.localizedDescription)")
            }
        }
        
        cosmosContainer.viewContext.automaticallyMergesChangesFromParent = true
        cosmosContainer.viewContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
    }
    
    func preserveQuantumState() {
        let crystalContext = cosmosContainer.viewContext
        
        if crystalContext.hasChanges {
            do {
                try crystalContext.save()
            } catch {
                print("Quantum collapse error: \(error.localizedDescription)")
            }
        }
    }
}

