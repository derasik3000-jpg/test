import Foundation
import CoreData

public final class PyxeloCoreStack {
    public static let shared = PyxeloCoreStack()
    
    public let container: NSPersistentContainer
    public var qylexContext: NSManagedObjectContext { container.viewContext }
    
    private init() {
        container = NSPersistentContainer(name: "PxeloModel")
        container.loadPersistentStores { desc, error in
            if let error = error {
                fatalError("Failed to load Pxelo store: \(error)")
            }
        }
        container.viewContext.automaticallyMergesChangesFromParent = true
        container.viewContext.mergePolicy = NSMergePolicy.mergeByPropertyObjectTrump
        
        vytexSeedTemplates()
        vytexEnsureSettings()
    }
    
    private func vytexSeedTemplates() {
        let req = ZaxorTemplate.vytexRequest()
        if (try? qylexContext.count(for: req)) ?? 0 > 0 { return }
        
        let templates: [(KrynexType, String, Int, Int)] = [
            (.putt, "Putting", 10, 40),
            (.chip, "Chip", 10, 25),
            (.drive, "Drive", 10, 20)
        ]
        
        for (type, name, dur, target) in templates {
            let t = ZaxorTemplate(context: qylexContext)
            t.id = UUID()
            t.typeRaw = type.rawValue
            t.name = name
            t.defaultDurationMin = Int16(dur)
            t.defaultTargetAttempts = Int16(target)
            t.createdAtUTC = Date()
        }
        
        try? qylexContext.save()
    }
    
    private func vytexEnsureSettings() {
        let req = NyxelSettings.vytexRequest()
        if (try? qylexContext.count(for: req)) ?? 0 > 0 { return }
        
        let s = NyxelSettings(context: qylexContext)
        s.id = UUID()
        s.hapticsEnabled = true
        s.endBeepEnabled = true
        s.onboardingCompleted = false
        let defaults = [0: 40, 1: 25, 2: 20] // putt, chip, drive
        s.defaultTargetsJSON = (try? JSONEncoder().encode(defaults)) ?? Data()
        s.createdAtUTC = Date()
        s.updatedAtUTC = Date()
        
        try? qylexContext.save()
    }
    
    public func gylexSave() throws {
        if qylexContext.hasChanges {
            try qylexContext.save()
        }
    }
}

