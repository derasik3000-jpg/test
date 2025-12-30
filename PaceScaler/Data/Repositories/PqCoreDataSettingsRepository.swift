import CoreData
import Foundation

final class PqCoreDataSettingsRepository: PqConfigRepo {
    private let context: NSManagedObjectContext
    
    init(context: NSManagedObjectContext) {
        self.context = context
    }
    
    @MainActor
    func pqRetrieveData() async throws -> SettingsDTO {
        let request: NSFetchRequest<Settings> = Settings.fetchRequest()
        let settings = try context.fetch(request).first ?? pqInitializeDefaultsRecord()
        return pqConvertToTransfer(settings)
    }
    
    @MainActor
    func pqPersistData(_ s: SettingsDTO) async throws {
        let request: NSFetchRequest<Settings> = Settings.fetchRequest()
        let settings = try context.fetch(request).first ?? Settings(context: context)
        
        settings.idValue = settings.idValue ?? UUID()
        settings.defSleepStartHour = Int16(s.defSleepStart.h)
        settings.defSleepStartMinute = Int16(s.defSleepStart.m)
        settings.defSleepEndHour = Int16(s.defSleepEnd.h)
        settings.defSleepEndMinute = Int16(s.defSleepEnd.m)
        settings.hapticsEnabled = s.hapticsEnabled
        
        try context.save()
    }
    
    private func pqInitializeDefaultsRecord() -> Settings {
        let settings = Settings(context: context)
        settings.idValue = UUID()
        settings.defSleepStartHour = 22
        settings.defSleepStartMinute = 30
        settings.defSleepEndHour = 23
        settings.defSleepEndMinute = 30
        settings.hapticsEnabled = true
        settings.seedLoaded = false
        try? context.save()
        return settings
    }
    
    private func pqConvertToTransfer(_ entity: Settings) -> SettingsDTO {
        SettingsDTO(
            defSleepStart: (h: Int(entity.defSleepStartHour), m: Int(entity.defSleepStartMinute)),
            defSleepEnd: (h: Int(entity.defSleepEndHour), m: Int(entity.defSleepEndMinute)),
            hapticsEnabled: entity.hapticsEnabled
        )
    }
}

