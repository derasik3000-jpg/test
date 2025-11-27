import CoreData
import Foundation

class MetricsCoreArchive: MetricsArchiveProtocol {
    private let cosmosController: ZephyrPersistenceController
    
    init(cosmosController: ZephyrPersistenceController = .nebula) {
        self.cosmosController = cosmosController
    }
    
    func retrieveMetrics() -> [MetricsRecordPrism] {
        let fetchRequest: NSFetchRequest<MetricsRecordEntity> = MetricsRecordEntity.fetchRequest()
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "chronoMark", ascending: false)]
        
        do {
            let entities = try cosmosController.cosmosContainer.viewContext.fetch(fetchRequest)
            return entities.compactMap { convertToPrism($0) }
        } catch {
            print("Metrics retrieval error: \(error)")
            return []
        }
    }
    
    func appendMetric(_ prism: MetricsRecordPrism) {
        let context = cosmosController.cosmosContainer.viewContext
        let entity = MetricsRecordEntity(context: context)
        
        entity.chronoMark = prism.chronoMark
        entity.averagePhaseLength = prism.averagePhaseLength
        entity.sessionCorrelationValue = prism.sessionCorrelationValue
        
        cosmosController.preserveQuantumState()
    }
    
    private func convertToPrism(_ entity: MetricsRecordEntity) -> MetricsRecordPrism {
        MetricsRecordPrism(
            chronoMark: entity.chronoMark ?? Date(),
            averagePhaseLength: entity.averagePhaseLength,
            sessionCorrelationValue: entity.sessionCorrelationValue
        )
    }
}

