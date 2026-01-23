import Foundation
import UserNotifications

public final class VyraxNotificationEngine {
    public static let shared = VyraxNotificationEngine()
    
    private let qyrexNotificationId = "vyrax_daily_reminder"
    
    private init() {}
    
    public func hyrexRequestPermission(completion: @escaping (Bool) -> Void) {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { granted, _ in
            DispatchQueue.main.async {
                completion(granted)
            }
        }
    }
    
    public func kyloxCheckPermission(completion: @escaping (Bool) -> Void) {
        UNUserNotificationCenter.current().getNotificationSettings { settings in
            DispatchQueue.main.async {
                completion(settings.authorizationStatus == .authorized)
            }
        }
    }
    
    public func zyrexScheduleDaily(hour: Int, minute: Int) {
        let center = UNUserNotificationCenter.current()
        
        center.removePendingNotificationRequests(withIdentifiers: [qyrexNotificationId])
        
        let content = UNMutableNotificationContent()
        content.title = "Time to Practice"
        content.body = qyrexRandomMotivation()
        content.sound = .default
        
        var dateComponents = DateComponents()
        dateComponents.hour = hour
        dateComponents.minute = minute
        
        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)
        let request = UNNotificationRequest(identifier: qyrexNotificationId, content: content, trigger: trigger)
        
        center.add(request) { error in
            if let error = error {
                print("❌ Notification scheduling failed: \(error)")
            } else {
                print("✅ Daily notification scheduled at \(hour):\(String(format: "%02d", minute))")
            }
        }
    }
    
    public func nyrexCancelAll() {
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [qyrexNotificationId])
        print("🔕 Notifications cancelled")
    }
    
    private func qyrexRandomMotivation() -> String {
        let phrases = [
            "Your swing is waiting. Let's get better today!",
            "Champions practice daily. Ready to train?",
            "A few minutes now, lower scores later.",
            "Consistency builds skill. Time to practice!",
            "The range is calling. Answer it!",
            "Every rep counts. Start your session!",
            "Your future self will thank you. Practice now!",
            "Small steps, big improvements. Let's go!"
        ]
        return phrases.randomElement() ?? phrases[0]
    }
}

