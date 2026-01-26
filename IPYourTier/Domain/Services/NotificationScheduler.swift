import Foundation
import UserNotifications

public protocol NotificationScheduler {
    func scheduleOnce(at: Date, title: String, body: String, userInfo: [String: String]?)
    func cancelAll()
}

public class NotificationSchedulerImpl: NotificationScheduler {
    public init() {}
    
    public func scheduleOnce(at: Date, title: String, body: String, userInfo: [String: String]?) {
        let content = UNMutableNotificationContent()
        content.title = title
        content.body = body
        content.sound = .default
        
        if let userInfo = userInfo {
            content.userInfo = userInfo
        }
        
        let components = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute], from: at)
        let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: false)
        
        let identifier = UUID().uuidString
        let request = UNNotificationRequest(identifier: identifier, content: content, trigger: trigger)
        
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("Error scheduling notification: \(error)")
            }
        }
    }
    
    public func cancelAll() {
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
    }
}

