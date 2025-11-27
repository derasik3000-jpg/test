import Foundation

struct ConfigurationPrism: Codable {
    var nightModeActivated: Bool
    var amplitudeLevel: Float
    var healthDataSyncEnabled: Bool
    var reminderTimestamps: [Date]
    var animationIntensity: Float
    
    init(nightModeActivated: Bool = false, amplitudeLevel: Float = 0.5, healthDataSyncEnabled: Bool = false, reminderTimestamps: [Date] = [], animationIntensity: Float = 1.0) {
        self.nightModeActivated = nightModeActivated
        self.amplitudeLevel = amplitudeLevel
        self.healthDataSyncEnabled = healthDataSyncEnabled
        self.reminderTimestamps = reminderTimestamps
        self.animationIntensity = animationIntensity
    }
}

