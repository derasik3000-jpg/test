import Foundation
import UserNotifications

// MARK: - ReminderNotificationScheduler
// Schedules local notifications for CareReminders.
// iOS allows max 64 pending notifications; we schedule up to 8 per recurring reminder.

final class ReminderNotificationScheduler {

    static let shared = ReminderNotificationScheduler()

    private let center = UNUserNotificationCenter.current()
    private let maxPerReminder = 8

    private init() {}

    // MARK: - Permission

    func requestAuthorizationIfNeeded() async -> Bool {
        let settings = await center.notificationSettings()
        switch settings.authorizationStatus {
        case .authorized, .provisional, .ephemeral:
            return true
        case .denied:
            return false
        case .notDetermined:
            let granted = (try? await center.requestAuthorization(options: [.alert, .sound, .badge])) ?? false
            return granted
        @unknown default:
            return false
        }
    }

    func requestAuthorization(completion: @escaping (Bool) -> Void) {
        center.requestAuthorization(options: [.alert, .sound, .badge]) { granted, _ in
            DispatchQueue.main.async { completion(granted) }
        }
    }

    // MARK: - Schedule

    func schedule(_ reminder: CareReminder) {
        requestAuthorization { [weak self] granted in
            guard granted, let self else { return }
            self.scheduleInternal(reminder)
        }
    }

    private func scheduleInternal(_ reminder: CareReminder) {
        cancel(reminderId: reminder.id)

        let (hour, minute) = parseTimeOfDay(reminder.timeOfDay)

        if reminder.isRecurring, let interval = reminder.recurringDays, interval > 0 {
            scheduleRecurring(reminder: reminder, hour: hour, minute: minute, interval: interval)
        } else {
            scheduleOneTime(reminder: reminder, hour: hour, minute: minute)
        }
    }

    private func scheduleOneTime(reminder: CareReminder, hour: Int, minute: Int) {
        let cal = Calendar.current
        var comps = cal.dateComponents([.year, .month, .day], from: reminder.dueDate)
        comps.hour = hour
        comps.minute = minute
        comps.second = 0

        guard let triggerDate = cal.date(from: comps), triggerDate > Date() else { return }

        let content = UNMutableNotificationContent()
        content.title = "🐾 \(reminder.title)"
        content.body = reminder.note.isEmpty ? "Time for pet care" : reminder.note
        content.sound = .default

        let trigger = UNCalendarNotificationTrigger(dateMatching: comps, repeats: false)
        let request = UNNotificationRequest(
            identifier: identifier(for: reminder.id, index: 0),
            content: content,
            trigger: trigger
        )
        center.add(request)
    }

    private func scheduleRecurring(reminder: CareReminder, hour: Int, minute: Int, interval: Int) {
        let cal = Calendar.current
        let today = cal.startOfDay(for: Date())
        var nextDate = cal.startOfDay(for: reminder.dueDate)

        // Advance to first future occurrence
        while nextDate < today {
            if interval == 365 {
                nextDate = cal.date(byAdding: .year, value: 1, to: nextDate) ?? nextDate
            } else {
                nextDate = cal.date(byAdding: .day, value: interval, to: nextDate) ?? nextDate
            }
        }

        var count = 0
        while count < maxPerReminder {
            var comps = cal.dateComponents([.year, .month, .day], from: nextDate)
            comps.hour = hour
            comps.minute = minute
            comps.second = 0

            guard let triggerDate = cal.date(from: comps), triggerDate > Date() else { break }

            let content = UNMutableNotificationContent()
            content.title = "🐾 \(reminder.title)"
            content.body = reminder.note.isEmpty ? "Time for pet care" : reminder.note
            content.sound = .default

            let trigger = UNCalendarNotificationTrigger(dateMatching: comps, repeats: false)
            let request = UNNotificationRequest(
                identifier: identifier(for: reminder.id, index: count),
                content: content,
                trigger: trigger
            )
            center.add(request)

            if interval == 365 {
                nextDate = cal.date(byAdding: .year, value: 1, to: nextDate) ?? nextDate
            } else {
                nextDate = cal.date(byAdding: .day, value: interval, to: nextDate) ?? nextDate
            }
            count += 1
        }
    }

    private func parseTimeOfDay(_ timeOfDay: String?) -> (hour: Int, minute: Int) {
        guard let s = timeOfDay, let colon = s.firstIndex(of: ":") else {
            return (9, 0)
        }
        let h = Int(s[..<colon]) ?? 9
        let m = Int(s[s.index(after: colon)...]) ?? 0
        return (max(0, min(23, h)), max(0, min(59, m)))
    }

    private func identifier(for reminderId: UUID, index: Int) -> String {
        "reminder_\(reminderId.uuidString)_\(index)"
    }

    // MARK: - Cancel

    func cancel(reminderId: UUID) {
        let prefix = "reminder_\(reminderId.uuidString)_"
        center.getPendingNotificationRequests { requests in
            let ids = requests
                .filter { $0.identifier.hasPrefix(prefix) }
                .map(\.identifier)
            guard !ids.isEmpty else { return }
            self.center.removePendingNotificationRequests(withIdentifiers: ids)
        }
    }

    // MARK: - Reschedule All

    func rescheduleAll() {
        let reminders = GroveStorage.shared.careReminders
        requestAuthorization { [weak self] granted in
            guard granted, let self else { return }
            for r in reminders {
                self.scheduleInternal(r)
            }
        }
    }
}
