import Foundation
import Combine
import SwiftUI
import CoreData
struct SystemClockProvider: ClockProvider {
    var currentMoment: Date {
        Date()
    }
}

final class ConfigVaultRepository: ConfigVaultProtocol {
    private let coordinator: PersistenceCoordinator
    
    init(coordinator: PersistenceCoordinator = .shared) {
        self.coordinator = coordinator
    }
    
    func isHapticsOn() -> AnyPublisher<Bool, Never> {
        Future { [weak self] promise in
            guard let self = self else {
                promise(.success(true))
                return
            }
            
            let request: NSFetchRequest<AppSettings> = AppSettings.fetchRequest()
            request.fetchLimit = 1
            
            do {
                let results = try self.coordinator.context.fetch(request)
                if let settings = results.first {
                    promise(.success(settings.hapticsEnabled))
                } else {
                    promise(.success(true))
                }
            } catch {
                promise(.success(true))
            }
        }.eraseToAnyPublisher()
    }
    
    func setHaptics(_ enabled: Bool) -> AnyPublisher<Void, Never> {
        Future { [weak self] promise in
            guard let self = self else {
                promise(.success(()))
                return
            }
            
            let request: NSFetchRequest<AppSettings> = AppSettings.fetchRequest()
            request.fetchLimit = 1
            
            do {
                let results = try self.coordinator.context.fetch(request)
                let settings: AppSettings
                
                if let existing = results.first {
                    settings = existing
                } else {
                    settings = AppSettings(context: self.coordinator.context)
                    settings.id = UUID()
                    settings.createdAt = Date()
                    settings.firstDayOfWeek = 0
                }
                
                settings.hapticsEnabled = enabled
                settings.updatedAt = Date()
                
                try self.coordinator.saveContext()
                promise(.success(()))
            } catch {
                promise(.success(()))
            }
        }.eraseToAnyPublisher()
    }
}

