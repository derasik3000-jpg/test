import CoreData
import Foundation

class VaporFlowCoreArchive: VaporFlowArchiveProtocol {
    private let cosmosController: ZephyrPersistenceController
    
    init(cosmosController: ZephyrPersistenceController = .nebula) {
        self.cosmosController = cosmosController
    }
    
    func retrieveAllQuantums() -> [VaporFlowPrism] {
        let fetchRequest: NSFetchRequest<VaporFlowEntity> = VaporFlowEntity.fetchRequest()
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "chronoStamp", ascending: false)]
        
        do {
            let entities = try cosmosController.cosmosContainer.viewContext.fetch(fetchRequest)
            return entities.compactMap { convertToPrism($0) }
        } catch {
            print("Retrieval quantum error: \(error)")
            return []
        }
    }
    
    func appendQuantum(_ prism: VaporFlowPrism) {
        let context = cosmosController.cosmosContainer.viewContext
        let entity = VaporFlowEntity(context: context)
        
        entity.flowIdentifier = prism.flowIdentifier
        entity.rhythmCategory = prism.rhythmCategory
        entity.durationPhase = Int16(prism.durationPhase)
        entity.chronoStamp = prism.chronoStamp
        entity.soundActivated = prism.soundActivated
        
        cosmosController.preserveQuantumState()
    }
    
    func retrieveRecentQuantums(threshold: Int) -> [VaporFlowPrism] {
        let allQuantums = retrieveAllQuantums()
        return Array(allQuantums.prefix(threshold))
    }
    
    private func convertToPrism(_ entity: VaporFlowEntity) -> VaporFlowPrism {
        VaporFlowPrism(
            flowIdentifier: entity.flowIdentifier ?? UUID(),
            rhythmCategory: entity.rhythmCategory ?? "",
            durationPhase: Int(entity.durationPhase),
            chronoStamp: entity.chronoStamp ?? Date(),
            soundActivated: entity.soundActivated
        )
    }
}

