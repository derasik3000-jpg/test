import CoreData
import Foundation

final class PqPersistenceController {
    static let shared = PqPersistenceController()
    
    let container: NSPersistentContainer
    
    var viewContext: NSManagedObjectContext {
        container.viewContext
    }
    
    func pqSpawnBackgroundContext() -> NSManagedObjectContext {
        container.newBackgroundContext()
    }
    
    private init() {
        container = NSPersistentContainer(name: "x59")
        container.viewContext.automaticallyMergesChangesFromParent = true
        
        var loadError: Error?
        let semaphore = DispatchSemaphore(value: 0)
        
        container.loadPersistentStores { description, error in
            if let error = error {
                loadError = error
                print("❌ Core Data failed to load: \(error.localizedDescription)")
                print("Description: \(description)")
            } else {
                print("✅ Core Data loaded successfully: \(description)")
            }
            semaphore.signal()
        }
        
        semaphore.wait()
        
        if let error = loadError {
            fatalError("Core Data failed to load: \(error.localizedDescription)")
        }
    }
    
    @MainActor
    func pqExecuteInitialSeed() async throws {
        print("🌱 Checking if seed needed...")
        
        let fetchRequest: NSFetchRequest<Settings> = Settings.fetchRequest()
        let settings = try? viewContext.fetch(fetchRequest).first
        
        if settings?.seedLoaded == true {
            print("✅ Seed already loaded, skipping")
            return
        }
        
        print("🌱 Starting seed...")
        
        let newSettings = Settings(context: viewContext)
        newSettings.idValue = UUID()
        newSettings.defSleepStartHour = 22
        newSettings.defSleepStartMinute = 30
        newSettings.defSleepEndHour = 23
        newSettings.defSleepEndMinute = 30
        newSettings.hapticsEnabled = true
        newSettings.seedLoaded = true
        print("✅ Settings created")
        
        let defaultSteps = [
            ("Dim lights", "Lower brightness in room", "lightbulb.fill", 0),
            ("Drink water", "Glass of water before bed", "drop.fill", 1),
            ("Put phone away", "No screens 30min before sleep", "iphone.slash", 2)
        ]
        
        for (title, desc, icon, order) in defaultSteps {
            let step = RitualStep(context: viewContext)
            step.idValue = UUID()
            step.titleText = title
            step.descText = desc
            step.iconName = icon
            step.orderIndex = Int16(order)
            step.isArchived = false
            print("✅ Created step: \(title)")
        }
        
        let defaultTags = ["stress", "late coffee", "no screens", "calm", "walk"]
        for tagName in defaultTags {
            let tag = Tag(context: viewContext)
            tag.idValue = UUID()
            tag.nameText = tagName
            tag.isArchived = false
            tag.createdAt = Date()
            print("✅ Created tag: \(tagName)")
        }
        
        print("💾 Saving seed data...")
        try viewContext.save()
        print("✅ Seed completed successfully!")
    }
}

