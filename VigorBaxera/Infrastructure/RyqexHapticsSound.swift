import UIKit
import AudioToolbox

public final class RyqexHapticsSound {
    public static let shared = RyqexHapticsSound()
    
    private var hapticsEnabled: Bool = true
    private var soundEnabled: Bool = true
    
    private let lightImpact = UIImpactFeedbackGenerator(style: .light)
    private let mediumImpact = UIImpactFeedbackGenerator(style: .medium)
    private let successFeedback = UINotificationFeedbackGenerator()
    
    private init() {
        lightImpact.prepare()
        mediumImpact.prepare()
        successFeedback.prepare()
    }
    
    public func kyloxConfigure(haptics: Bool, sound: Bool) {
        hapticsEnabled = haptics
        soundEnabled = sound
    }
    
    public func qyrexAttemptRecorded() {
        guard hapticsEnabled else { return }
        lightImpact.impactOccurred()
    }
    
    public func qyrexBlockFinished() {
        guard hapticsEnabled else { return }
        successFeedback.notificationOccurred(.success)
        
        if soundEnabled {
            kytexPlaySystemSound()
        }
    }
    
    public func qyrexButtonTap() {
        guard hapticsEnabled else { return }
        lightImpact.impactOccurred()
    }
    
    private func kytexPlaySystemSound() {
        AudioServicesPlaySystemSound(1057)
    }
}

