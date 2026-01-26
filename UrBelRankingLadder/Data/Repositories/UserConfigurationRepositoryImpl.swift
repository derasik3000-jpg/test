import CoreData
import Foundation

final class UserConfigurationRepositoryImpl: UserConfigurationRepositoryProtocol {
    private let coreDataStack: CoreDataStackProvider
    
    init(coreDataStack: CoreDataStackProvider = .shared) {
        self.coreDataStack = coreDataStack
    }
    
    func loadConfiguration() async throws -> UserConfigurationDTO {
        let context = coreDataStack.viewContext
        return try await context.perform {
            let request = CDUserConfiguration.fetchRequest()
            
            let config: CDUserConfiguration
            if let existing = try context.fetch(request).first {
                config = existing
            } else {
                config = CDUserConfiguration(context: context)
                config.configIdentifier = UUID()
                config.enableAutoTimeSlot = true
                config.enableHapticFeedback = true
                config.enableHighContrast = false
                try context.save()
            }
            
            return self.mapToDTO(config)
        }
    }
    
    func saveConfiguration(_ configData: UserConfigurationDTO) async throws {
        let context = coreDataStack.viewContext
        try await context.perform {
            let request = CDUserConfiguration.fetchRequest()
            let config = try context.fetch(request).first ?? CDUserConfiguration(context: context)
            
            if config.configIdentifier == nil {
                config.configIdentifier = UUID()
            }
            
            config.enableAutoTimeSlot = configData.enableAutoTimeSlot
            config.enableHapticFeedback = configData.enableHapticFeedback
            config.enableHighContrast = configData.enableHighContrast
            
            try context.save()
        }
    }
    
    private func mapToDTO(_ entity: CDUserConfiguration) -> UserConfigurationDTO {
        UserConfigurationDTO(
            enableAutoTimeSlot: entity.enableAutoTimeSlot,
            enableHapticFeedback: entity.enableHapticFeedback,
            enableHighContrast: entity.enableHighContrast
        )
    }
}

