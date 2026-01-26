import Foundation

public struct UserConfigurationDTO: Hashable, Codable {
    public var enableAutoTimeSlot: Bool
    public var enableHapticFeedback: Bool
    public var enableHighContrast: Bool
    
    public init(enableAutoTimeSlot: Bool, enableHapticFeedback: Bool, enableHighContrast: Bool) {
        self.enableAutoTimeSlot = enableAutoTimeSlot
        self.enableHapticFeedback = enableHapticFeedback
        self.enableHighContrast = enableHighContrast
    }
}

