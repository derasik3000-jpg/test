import Foundation
import UserNotifications

class GamingNotificationService: GamingNotificationServiceProtocol {
    private let center = UNUserNotificationCenter.current()
    
    func schedulePlanReminder(planId: UUID, date: Date, programId: UUID?) {
        let content = UNMutableNotificationContent()
        content.title = "Time for gaming!"
        content.body = programId != nil ? "Time to play your game program!" : "Check your gaming plan!"
        content.sound = .default
        
        let calendar = Calendar.current
        let components = calendar.dateComponents([.year, .month, .day, .hour, .minute], from: date)
        let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: false)
        
        let identifier = "plan_\(planId.uuidString)"
        let request = UNNotificationRequest(identifier: identifier, content: content, trigger: trigger)
        
        center.add(request)
    }
    
    func schedulePlanReminder(planId: UUID, date: Date, recordId: UUID?) {
        schedulePlanReminder(planId: planId, date: date, programId: nil)
    }
    
    func cancelPlanReminder(planId: UUID) {
        center.removePendingNotificationRequests(withIdentifiers: ["plan_\(planId.uuidString)"])
    }
    
    func requestAuthorization() async -> Bool {
        do {
            return try await center.requestAuthorization(options: [.alert, .sound, .badge])
        } catch {
            return false
        }
    }
}

