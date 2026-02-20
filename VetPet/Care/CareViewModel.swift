import Foundation
import Combine

// MARK: - CareViewModel
// Drives the Care tab: calendar, reminders, vet visits

final class CareViewModel: ObservableObject {

    @Published var activeCompanion: CompanionProfile? = nil
    @Published var allCompanions: [CompanionProfile] = []
    @Published var selectedDate: Date = Date()
    @Published var displayedMonth: Date = Date()
    @Published var remindersForSelectedDay: [CareReminder] = []
    @Published var vetVisitsForSelectedDay: [VetVisit] = []
    @Published var dateKeysWithEvents: Set<String> = []
    @Published var calendarDays: [CareCalendarDay] = []
    @Published var toastText: String? = nil

    var selectedDateKey: String { selectedDate.wellnessDateKey }
    var selectedDateFormatted: String {
        let f = DateFormatter()
        f.dateStyle = .medium
        f.locale = Locale(identifier: "en_US")
        return f.string(from: selectedDate)
    }
    var isSelectedToday: Bool { Calendar.current.isDateInToday(selectedDate) }

    init() {
        refresh()
    }

    func refresh() {
        let storage = GroveStorage.shared
        allCompanions = storage.companions

        if let current = activeCompanion,
           allCompanions.contains(where: { $0.id == current.id }) {
            // keep
        } else {
            activeCompanion = allCompanions.first
        }

        refreshCalendar()
        loadSelectedDay()
    }

    func selectCompanion(_ companion: CompanionProfile?) {
        activeCompanion = companion
        refresh()
    }

    func selectDay(_ date: Date) {
        selectedDate = date
        loadSelectedDay()
    }

    func selectDateKey(_ key: String) {
        guard let date = key.dateFromWellnessKey else { return }
        selectedDate = date
        loadSelectedDay()
    }

    func changeMonth(by delta: Int) {
        guard let newMonth = Calendar.current.date(byAdding: .month, value: delta, to: displayedMonth) else { return }
        displayedMonth = newMonth
        refreshCalendar()
    }

    private func refreshCalendar() {
        let cal = Calendar.current
        guard let range = cal.range(of: .day, in: .month, for: displayedMonth),
              let start = cal.date(from: cal.dateComponents([.year, .month], from: displayedMonth)) else {
            calendarDays = []
            return
        }

        let companionId = activeCompanion?.id
        let reminderKeys = GroveStorage.shared.dateKeysWithReminders(month: displayedMonth, companionId: companionId)
        let visitKeys = GroveStorage.shared.dateKeysWithVetVisits(month: displayedMonth, companionId: companionId)
        dateKeysWithEvents = reminderKeys.union(visitKeys)

        var days: [CareCalendarDay] = []
        for dayOffset in range {
            guard let date = cal.date(byAdding: .day, value: dayOffset - 1, to: start) else { continue }
            let key = date.wellnessDateKey
            let hasEvent = dateKeysWithEvents.contains(key)
            let isSelected = key == selectedDateKey
            let isToday = cal.isDateInToday(date)

            days.append(CareCalendarDay(
                date: date,
                dateKey: key,
                dayNumber: cal.component(.day, from: date),
                weekdayLabel: cal.shortWeekdaySymbols[cal.component(.weekday, from: date) - 1].uppercased(),
                hasEvent: hasEvent,
                isSelected: isSelected,
                isToday: isToday
            ))
        }
        calendarDays = days
    }

    private func loadSelectedDay() {
        let companionId = activeCompanion?.id
        remindersForSelectedDay = GroveStorage.shared.remindersFor(date: selectedDate, companionId: companionId)
        vetVisitsForSelectedDay = GroveStorage.shared.vetVisitsFor(date: selectedDate, companionId: companionId)
    }

    func deleteReminder(_ reminder: CareReminder) {
        GroveStorage.shared.removeCareReminder(id: reminder.id)
        loadSelectedDay()
        refreshCalendar()
        showToast("Reminder removed")
    }

    func deleteVetVisit(_ visit: VetVisit) {
        GroveStorage.shared.removeVetVisit(id: visit.id)
        loadSelectedDay()
        refreshCalendar()
        showToast("Visit removed")
    }

    private func showToast(_ text: String) {
        toastText = text
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) { [weak self] in
            if self?.toastText == text { self?.toastText = nil }
        }
    }
}

// MARK: - CareCalendarDay

struct CareCalendarDay: Identifiable, Equatable {
    let id = UUID()
    let date: Date
    let dateKey: String
    let dayNumber: Int
    let weekdayLabel: String
    let hasEvent: Bool
    let isSelected: Bool
    let isToday: Bool
}
