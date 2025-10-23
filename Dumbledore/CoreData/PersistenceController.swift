// PersistenceController.swift
import CoreData

struct PersistenceController {
    static let shared = PersistenceController()

    static var preview: PersistenceController = {
        let result = PersistenceController(inMemory: true)
        let viewContext = result.container.viewContext
        
        // Create sample data for previews
        let sampleScenario = Scenario(context: viewContext)
        sampleScenario.id = UUID()
        sampleScenario.title = "Restaurant: Ordering Food"
        sampleScenario.levelMin = 1
        sampleScenario.goals = "[\"order_item\",\"ask_price\",\"no_onion\"]"
        sampleScenario.topics = "[\"food\",\"restaurant\"]"
        sampleScenario.graphRef = "restaurant_order.json"
        sampleScenario.createdAt = Date()
        sampleScenario.updatedAt = Date()
        
        do {
            try viewContext.save()
        } catch {
            let nsError = error as NSError
            fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
        }
        return result
    }()

    let container: NSPersistentContainer

    init(inMemory: Bool = false) {
        container = NSPersistentContainer(name: "IWingMoveModel")
        if inMemory {
            container.persistentStoreDescriptions.first!.url = URL(fileURLWithPath: "/dev/null")
        }
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        container.viewContext.automaticallyMergesChangesFromParent = true
    }
}
