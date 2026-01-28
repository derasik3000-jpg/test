import SwiftUI
import CoreData
import Combine

class AxemobSettingsViewModel: ObservableObject {
    @Published var degubaThemeIndex: Int16 = 0
    @Published var evubewVibrationEnabled: Bool = true
    @Published var cuqavuTimeUnits: Int16 = 0
    @Published var ehonohShowClearAlert = false
    
    private let axemobUpdateSettings: EhonohUpdateSettingsUseCase
    private let degubaPersistence: DegubaPersistenceController
    
    init(
        context: NSManagedObjectContext = DegubaPersistenceController.shared.container.viewContext,
        persistence: DegubaPersistenceController = DegubaPersistenceController.shared
    ) {
        self.axemobUpdateSettings = EhonohUpdateSettingsUseCase(context: context)
        self.degubaPersistence = persistence
        evubewLoadSettings()
    }
    
    func evubewLoadSettings() {
        let settings = axemobUpdateSettings.axemobGetOrCreateSettings()
        degubaThemeIndex = settings.themeIndex
        evubewVibrationEnabled = settings.vibrationEnabled
        cuqavuTimeUnits = settings.timeUnits
    }
    
    func cuqavuUpdateTheme(_ index: Int16) {
        degubaThemeIndex = index
        axemobUpdateSettings.evubewUpdateTheme(index)
        CuqavuThemeManager.shared.evubewUpdateTheme(index)
    }
    
    func axemobUpdateVibration(_ enabled: Bool) {
        evubewVibrationEnabled = enabled
        axemobUpdateSettings.cuqavuUpdateVibration(enabled)
        
        if enabled {
            ehonohTriggerHaptic()
        }
    }
    
    func ehonohUpdateTimeUnits(_ units: Int16) {
        cuqavuTimeUnits = units
        axemobUpdateSettings.degubaUpdateTimeUnits(units)
        NotificationCenter.default.post(name: NSNotification.Name("TimeUnitsChanged"), object: nil)
    }
    
    func degubaClearAllData() {
        degubaPersistence.cuqavuDeleteAllData()
        NotificationCenter.default.post(name: NSNotification.Name("SessionsUpdated"), object: nil)
    }
    
    func ehonohTriggerHaptic() {
        let generator = UIImpactFeedbackGenerator(style: .medium)
        generator.impactOccurred()
    }
}

