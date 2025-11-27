import CoreData
import Foundation

class RestCycleCoreArchive: RestCycleArchiveProtocol {
    private let cosmosController: ZephyrPersistenceController
    
    init(cosmosController: ZephyrPersistenceController = .nebula) {
        self.cosmosController = cosmosController
    }
    
    func retrieveAllCycles() -> [RestCyclePrism] {
        let fetchRequest: NSFetchRequest<RestCycleEntity> = RestCycleEntity.fetchRequest()
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "initiationMoment", ascending: false)]
        
        do {
            let entities = try cosmosController.cosmosContainer.viewContext.fetch(fetchRequest)
            return entities.compactMap { convertToPrism($0) }
        } catch {
            print("Cycle retrieval error: \(error)")
            return []
        }
    }
    
    func appendCycle(_ prism: RestCyclePrism) {
        let context = cosmosController.cosmosContainer.viewContext
        let entity = RestCycleEntity(context: context)
        
        entity.cycleIdentifier = prism.cycleIdentifier
        entity.initiationMoment = prism.initiationMoment
        entity.terminationMoment = prism.terminationMoment
        entity.qualityMetric = prism.qualityMetric.map { Int16($0) } ?? 0
        entity.commentNote = prism.commentNote
        
        if let encoded = try? JSONEncoder().encode(prism.breathFlowLinks) {
            entity.breathFlowLinks = encoded as NSObject
        } else {
            entity.breathFlowLinks = Data() as NSObject
        }
        
        cosmosController.preserveQuantumState()
    }
    
    func retrieveRecentCycles(threshold: Int) -> [RestCyclePrism] {
        let allCycles = retrieveAllCycles()
        return Array(allCycles.prefix(threshold))
    }
    
    private func convertToPrism(_ entity: RestCycleEntity) -> RestCyclePrism {
        var breathLinks: [UUID] = []
        
        if let data = entity.breathFlowLinks as? Data {
            breathLinks = (try? JSONDecoder().decode([UUID].self, from: data)) ?? []
        }
        
        return RestCyclePrism(
            cycleIdentifier: entity.cycleIdentifier ?? UUID(),
            initiationMoment: entity.initiationMoment ?? Date(),
            terminationMoment: entity.terminationMoment ?? Date(),
            qualityMetric: entity.qualityMetric > 0 ? Int(entity.qualityMetric) : nil,
            breathFlowLinks: breathLinks,
            commentNote: entity.commentNote
        )
    }
}

