import CoreData
import Foundation

class ConfigurationCoreArchive: ConfigurationArchiveProtocol {
    private let cosmosController: ZephyrPersistenceController
    
    init(cosmosController: ZephyrPersistenceController = .nebula) {
        self.cosmosController = cosmosController
    }
    
    func retrieveConfiguration() -> ConfigurationPrism {
        let fetchRequest: NSFetchRequest<ConfigurationEntity> = ConfigurationEntity.fetchRequest()
        
        do {
            let entities = try cosmosController.cosmosContainer.viewContext.fetch(fetchRequest)
            if let entity = entities.first {
                return convertToPrism(entity)
            }
        } catch {
            print("Config retrieval error: \(error)")
        }
        
        return ConfigurationPrism()
    }
    
    func modifyConfiguration(_ prism: ConfigurationPrism) {
        let context = cosmosController.cosmosContainer.viewContext
        let fetchRequest: NSFetchRequest<ConfigurationEntity> = ConfigurationEntity.fetchRequest()
        
        do {
            let entities = try context.fetch(fetchRequest)
            let entity = entities.first ?? ConfigurationEntity(context: context)
            
            entity.nightModeActivated = prism.nightModeActivated
            entity.amplitudeLevel = prism.amplitudeLevel
            entity.healthDataSyncEnabled = prism.healthDataSyncEnabled
            entity.animationIntensity = prism.animationIntensity
            
            if let encoded = try? JSONEncoder().encode(prism.reminderTimestamps) {
                entity.reminderTimestamps = encoded as NSObject
            } else {
                entity.reminderTimestamps = Data() as NSObject
            }
            
            cosmosController.preserveQuantumState()
        } catch {
            print("Config modification error: \(error)")
        }
    }
    
    private func convertToPrism(_ entity: ConfigurationEntity) -> ConfigurationPrism {
        var reminders: [Date] = []
        
        if let data = entity.reminderTimestamps as? Data {
            reminders = (try? JSONDecoder().decode([Date].self, from: data)) ?? []
        }
        
        return ConfigurationPrism(
            nightModeActivated: entity.nightModeActivated,
            amplitudeLevel: entity.amplitudeLevel,
            healthDataSyncEnabled: entity.healthDataSyncEnabled,
            reminderTimestamps: reminders,
            animationIntensity: entity.animationIntensity
        )
    }
}

