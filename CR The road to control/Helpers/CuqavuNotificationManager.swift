import Foundation
import UserNotifications
import UIKit
import Combine

class CuqavuNotificationManager: NSObject, ObservableObject {
    static let shared = CuqavuNotificationManager()
    
    @Published var evubewNotificationsEnabled: Bool {
        didSet {
            UserDefaults.standard.set(evubewNotificationsEnabled, forKey: "notificationsEnabled")
        }
    }
    
    @Published var degubaSelectedHour: Int {
        didSet {
            UserDefaults.standard.set(degubaSelectedHour, forKey: "notificationHour")
        }
    }
    
    @Published var axemobSelectedMinute: Int {
        didSet {
            UserDefaults.standard.set(axemobSelectedMinute, forKey: "notificationMinute")
        }
    }
    
    @Published var cuqavuNotificationPermissionGranted = false
    
    private override init() {
        self.evubewNotificationsEnabled = UserDefaults.standard.bool(forKey: "notificationsEnabled")
        self.degubaSelectedHour = UserDefaults.standard.object(forKey: "notificationHour") as? Int ?? 9
        self.axemobSelectedMinute = UserDefaults.standard.object(forKey: "notificationMinute") as? Int ?? 0
        super.init()
        ehonohCheckNotificationPermission()
    }
    
    func ehonohCheckNotificationPermission() {
        UNUserNotificationCenter.current().getNotificationSettings { settings in
            DispatchQueue.main.async {
                self.cuqavuNotificationPermissionGranted = settings.authorizationStatus == .authorized
            }
        }
    }
    
    func axemobRequestNotificationPermission(completion: @escaping (Bool) -> Void) {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
            DispatchQueue.main.async {
                self.cuqavuNotificationPermissionGranted = granted
                completion(granted)
            }
        }
    }
    
    func evubewScheduleDailyNotification(hour: Int, minute: Int) {
        // Отменяем все существующие уведомления
        degubaCancelAllNotifications()
        
        let content = UNMutableNotificationContent()
        content.title = "Time for Productivity! 💪"
        content.body = axemobGetMotivationalMessage()
        content.sound = .default
        content.badge = 1
        
        // Устанавливаем время
        var dateComponents = DateComponents()
        dateComponents.hour = hour
        dateComponents.minute = minute
        
        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)
        let request = UNNotificationRequest(identifier: "dailyReminder", content: content, trigger: trigger)
        
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("Error scheduling notification: \(error.localizedDescription)")
            }
        }
    }
    
    func degubaCancelAllNotifications() {
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
        UNUserNotificationCenter.current().removeAllDeliveredNotifications()
        UIApplication.shared.applicationIconBadgeNumber = 0
    }
    
    private func axemobGetMotivationalMessage() -> String {
        let messages = [
            "Track your progress today and stay consistent! 🌟",
            "Every session counts. Start tracking now! 🚀",
            "Your productivity journey continues today! 💼",
            "Time to log your activities and reach your goals! 🎯",
            "Stay on track! Document your day's progress! 📊",
            "Don't forget to track your productivity today! ⏰",
            "Keep the momentum going! Track your sessions! 🔥",
            "Your future self will thank you for tracking today! 🌈"
        ]
        return messages.randomElement() ?? messages[0]
    }
    
    func cuqavuOpenSystemSettings() {
        if let settingsUrl = URL(string: UIApplication.openSettingsURLString) {
            if UIApplication.shared.canOpenURL(settingsUrl) {
                UIApplication.shared.open(settingsUrl)
            }
        }
    }
}

