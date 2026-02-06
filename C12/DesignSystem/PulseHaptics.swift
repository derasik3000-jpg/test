//
//  PulseHaptics.swift
//  PULSE
//
//  Design System - Haptic Feedback
//

import UIKit

struct PulseHaptics {
    
    private static let impactGenerator = UIImpactFeedbackGenerator(style: .medium)
    private static let selectionGenerator = UISelectionFeedbackGenerator()
    private static let notificationGenerator = UINotificationFeedbackGenerator()
    
    // MARK: - Prepare
    
    static func prepare() {
        impactGenerator.prepare()
        selectionGenerator.prepare()
        notificationGenerator.prepare()
    }
    
    // MARK: - Impact
    
    static func light() {
        let generator = UIImpactFeedbackGenerator(style: .light)
        generator.impactOccurred()
    }
    
    static func medium() {
        impactGenerator.impactOccurred()
    }
    
    static func heavy() {
        let generator = UIImpactFeedbackGenerator(style: .heavy)
        generator.impactOccurred()
    }
    
    // MARK: - Selection
    
    static func selection() {
        selectionGenerator.selectionChanged()
    }
    
    // MARK: - Notification
    
    static func success() {
        notificationGenerator.notificationOccurred(.success)
    }
    
    static func warning() {
        notificationGenerator.notificationOccurred(.warning)
    }
    
    static func error() {
        notificationGenerator.notificationOccurred(.error)
    }
    
    // MARK: - Pulse-Specific
    
    static func beat() {
        medium()
    }
    
    static func moodChange() {
        selection()
    }
    
    static func journeyUnlock() {
        success()
    }
}
