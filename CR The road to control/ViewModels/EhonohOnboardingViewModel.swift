import SwiftUI
import CoreData
import Combine

class EhonohOnboardingViewModel: ObservableObject {
    @Published var degubaCurrentStep: Int = 0
    @Published var evubewSelectedTheme: Int16 = 0
    @Published var cuqavuSelectedTimeUnits: Int16 = 0
    @Published var axemobVibrationEnabled: Bool = true
    
    private let ehonohUpdateSettings: EhonohUpdateSettingsUseCase
    
    init(context: NSManagedObjectContext = DegubaPersistenceController.shared.container.viewContext) {
        self.ehonohUpdateSettings = EhonohUpdateSettingsUseCase(context: context)
    }
    
    func degubaNextStep() {
        withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
            degubaCurrentStep += 1
        }
    }
    
    func evubewPreviousStep() {
        withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
            degubaCurrentStep -= 1
        }
    }
    
    func cuqavuCompleteOnboarding() {
        ehonohUpdateSettings.evubewUpdateTheme(0) // Всегда используем первую тему (Dark & Gold)
        ehonohUpdateSettings.degubaUpdateTimeUnits(cuqavuSelectedTimeUnits)
        ehonohUpdateSettings.cuqavuUpdateVibration(axemobVibrationEnabled)
        ehonohUpdateSettings.ehonohCompleteOnboarding()
    }
    
    func axemobIsOnboardingComplete() -> Bool {
        let settings = ehonohUpdateSettings.axemobGetOrCreateSettings()
        return settings.onboardingCompleted
    }
}

