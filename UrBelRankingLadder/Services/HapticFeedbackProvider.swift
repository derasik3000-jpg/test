import UIKit

final class HapticFeedbackProvider {
    nonisolated(unsafe) static let shared = HapticFeedbackProvider()
    
    private let impactLight = UIImpactFeedbackGenerator(style: .light)
    private let impactMedium = UIImpactFeedbackGenerator(style: .medium)
    private let notificationGenerator = UINotificationFeedbackGenerator()
    private let selectionGenerator = UISelectionFeedbackGenerator()
    
    private init() {
        impactLight.prepare()
        impactMedium.prepare()
    }
    
    func triggerSelection() {
        selectionGenerator.selectionChanged()
    }
    
    func triggerLightImpact() {
        impactLight.impactOccurred()
    }
    
    func triggerMediumImpact() {
        impactMedium.impactOccurred()
    }
    
    func triggerSuccess() {
        notificationGenerator.notificationOccurred(.success)
    }
    
    func triggerWarning() {
        notificationGenerator.notificationOccurred(.warning)
    }
}

