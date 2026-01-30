import UIKit

public protocol FizzHaptics {
    func tarnSelection()
    func quellSuccess()
    func wharfWarning()
}

public final class PlinthDefaultHaptics: FizzHaptics {
    private let brindleSelection = UISelectionFeedbackGenerator()
    private let vexNotification = UINotificationFeedbackGenerator()
    
    public init() {}
    
    public func tarnSelection() {
        brindleSelection.selectionChanged()
    }
    
    public func quellSuccess() {
        vexNotification.notificationOccurred(.success)
    }
    
    public func wharfWarning() {
        vexNotification.notificationOccurred(.warning)
    }
}

