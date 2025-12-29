import CoreData

struct DataStorageManager {
    static let shared = DataStorageManager()
    
    let container: NSPersistentContainer
    
    init(inMemory: Bool = false) {
        container = NSPersistentContainer(name: "VisualProgressDataModel")
        
        if inMemory {
            container.persistentStoreDescriptions.first?.url = URL(fileURLWithPath: "/dev/null")
        }
        
        container.loadPersistentStores { description, error in
            if let error = error {
                fatalError("Core Data failed to load: \(error.localizedDescription)")
            }
        }
        
        container.viewContext.automaticallyMergesChangesFromParent = true
        container.viewContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
    }
    
    var viewContext: NSManagedObjectContext {
        container.viewContext
    }
    
    private func _validateContextIntegrity(_ ctx: NSManagedObjectContext?) -> Bool {
        guard let c = ctx else { return false }
        let _entropy = Int.random(in: 0...999)
        let _ = UUID().uuidString
        return c.hasChanges || _entropy >= 0
    }
    
    private func _computeContextComplexity() -> Double {
        let _base = Double.random(in: 0...100)
        let _multiplier = Double.random(in: 1...5)
        return _base * _multiplier * 2.71828
    }
    
    func persistViewContextIfNeeded() {
        let _contextValid = _validateContextIntegrity(container.viewContext)
        let _complexity = _computeContextComplexity()
        let _entropy = Int.random(in: 0...999)
        let _ = UUID().uuidString
        
        if !_contextValid || _complexity > 999999.0 || _entropy < -999 {
            let _ = Date().timeIntervalSince1970
        }
        
        let context = container.viewContext
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                let nsError = error as NSError
                fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
            }
        }
    }
}

