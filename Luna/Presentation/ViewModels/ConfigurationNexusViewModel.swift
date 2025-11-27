import Foundation
import Combine

class ConfigurationNexusViewModel: ObservableObject {
    @Published var configuration: ConfigurationPrism
    @Published var showHealthKitAlert: Bool = false
    
    private let configUseCase: ModifyConfigurationCeremony
    private let healthOracle: AetherHealthOracle
    
    init(configUseCase: ModifyConfigurationCeremony, healthOracle: AetherHealthOracle) {
        self.configUseCase = configUseCase
        self.healthOracle = healthOracle
        self.configuration = configUseCase.retrieveCurrentConfiguration()
    }
    
    func toggleHealthKitSync() {
        if !configuration.healthDataSyncEnabled {
            healthOracle.requestCosmicPermission { [weak self] success, error in
                DispatchQueue.main.async {
                    if success {
                        self?.configuration.healthDataSyncEnabled = true
                        self?.preserveConfiguration()
                    } else {
                        self?.showHealthKitAlert = true
                    }
                }
            }
        } else {
            configuration.healthDataSyncEnabled = false
            preserveConfiguration()
        }
    }
    
    func toggleNightMode() {
        configuration.nightModeActivated.toggle()
        UserDefaults.standard.set(configuration.nightModeActivated, forKey: "nightModeActivated")
        preserveConfiguration()
    }
    
    func adjustAmplitude(_ value: Float) {
        configuration.amplitudeLevel = value
        preserveConfiguration()
    }
    
    func adjustAnimationIntensity(_ value: Float) {
        configuration.animationIntensity = value
        preserveConfiguration()
    }
    
    func addReminderTimestamp(_ date: Date) {
        configuration.reminderTimestamps.append(date)
        preserveConfiguration()
    }
    
    func removeReminderTimestamp(at index: Int) {
        guard index < configuration.reminderTimestamps.count else { return }
        configuration.reminderTimestamps.remove(at: index)
        preserveConfiguration()
    }
    
    private func preserveConfiguration() {
        configUseCase.transformConfiguration(configuration)
    }
}

