import Foundation
import CoreData

class GamingPreferenceRepository: GamingPreferenceRepositoryProtocol {
    private let container: GamingDataContainer
    private let defaultId = UUID(uuidString: "00000000-0000-0000-0000-000000000001")!
    
    init(container: GamingDataContainer = .shared) {
        self.container = container
    }
    
    func update(_ draft: GamingPreferenceDraft) throws -> GamingPreference {
        let request = GamingPreferenceEntity.fetchRequest()
        request.predicate = NSPredicate(format: "id == %@", defaultId as CVarArg)
        
        let entity: GamingPreferenceEntity
        if let existing = try? container.context.fetch(request).first {
            entity = existing
        } else {
            entity = GamingPreferenceEntity(context: container.context)
            entity.id = defaultId
        }
        
        entity.iconColorHex = draft.iconColorHex
        entity.iconViewType = draft.iconViewType
        entity.lastExportDate = draft.lastExportDate
        
        container.saveContext()
        return entity.toPreference()
    }
    
    func get() -> GamingPreference {
        let request = GamingPreferenceEntity.fetchRequest()
        request.predicate = NSPredicate(format: "id == %@", defaultId as CVarArg)
        
        if let entity = try? container.context.fetch(request).first {
            return entity.toPreference()
        }
        
        return GamingPreference(
            id: defaultId,
            iconColorHex: "#3F9EFF",
            iconViewType: "joystick",
            lastExportDate: nil
        )
    }
}

