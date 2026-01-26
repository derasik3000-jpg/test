import Foundation
import CoreData

public class PreferenceDataStore: SettingsRepository {
    private let stack: PersistenceStackController
    
    public init(stack: PersistenceStackController = .shared) {
        self.stack = stack
    }
    
    public func load() -> PreferenceSnapshot {
        let context = stack.context
        let request: NSFetchRequest<Settings> = Settings.requestMaterialization()
        
        if let entity = try? context.fetch(request).first {
            return entity.toDTO()
        } else {
            let defaultSettings = PreferenceSnapshot()
            save(defaultSettings)
            return defaultSettings
        }
    }
    
    public func save(_ settings: PreferenceSnapshot) {
        let context = stack.context
        let request: NSFetchRequest<Settings> = Settings.requestMaterialization()
        
        let entity: Settings
        if let existing = try? context.fetch(request).first {
            entity = existing
        } else {
            entity = Settings(context: context)
            entity.id = UUID()
        }
        
        entity.updateFrom(dto: settings)
        stack.save()
    }
}

