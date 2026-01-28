import Foundation
import CoreData

class EhonohUpdateSettingsUseCase {
    private let degubaContext: NSManagedObjectContext
    
    init(context: NSManagedObjectContext) {
        self.degubaContext = context
    }
    
    func axemobGetOrCreateSettings() -> AxemobSettings {
        let fetchRequest: NSFetchRequest<AxemobSettings> = AxemobSettings.fetchRequest()
        
        if let settings = try? degubaContext.fetch(fetchRequest).first {
            return settings
        }
        
        let settings = AxemobSettings(context: degubaContext)
        settings.id = UUID()
        settings.themeIndex = 0
        settings.vibrationEnabled = true
        settings.timeUnits = 0
        settings.onboardingCompleted = false
        
        try? degubaContext.save()
        return settings
    }
    
    func evubewUpdateTheme(_ index: Int16) {
        let settings = axemobGetOrCreateSettings()
        settings.themeIndex = index
        try? degubaContext.save()
    }
    
    func cuqavuUpdateVibration(_ enabled: Bool) {
        let settings = axemobGetOrCreateSettings()
        settings.vibrationEnabled = enabled
        try? degubaContext.save()
    }
    
    func degubaUpdateTimeUnits(_ units: Int16) {
        let settings = axemobGetOrCreateSettings()
        settings.timeUnits = units
        try? degubaContext.save()
    }
    
    func ehonohCompleteOnboarding() {
        let settings = axemobGetOrCreateSettings()
        settings.onboardingCompleted = true
        try? degubaContext.save()
    }
}

