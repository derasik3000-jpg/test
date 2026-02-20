import Foundation

// MARK: - Care Reminder Kind

enum CareReminderKind: String, Codable, CaseIterable, Identifiable {
    case pills      = "pills"
    case vet        = "vet"
    case groomer    = "groomer"
    case vaccine    = "vaccine"
    case birthday   = "birthday"
    case skinNote   = "skin_note"

    var id: String { rawValue }

    var icon: String {
        switch self {
        case .pills:    return "pills.fill"
        case .vet:      return "stethoscope"
        case .groomer:  return "scissors"
        case .vaccine:  return "syringe.fill"
        case .birthday: return "birthday.cake.fill"
        case .skinNote: return "hand.raised.fingers.spread.fill"
        }
    }

    var displayName: String {
        switch self {
        case .pills:    return "Pills"
        case .vet:      return "Vet Visit"
        case .groomer:  return "Groomer"
        case .vaccine:  return "Vaccine"
        case .birthday: return "Birthday"
        case .skinNote: return "Skin / Notes"
        }
    }
}

// MARK: - Care Reminder

struct CareReminder: Codable, Identifiable, Equatable {
    let id: UUID
    var companionId: UUID?
    var kindId: String       // CareReminderKind.rawValue or "custom_<uuid>"
    var title: String
    var dueDate: Date
    var timeOfDay: String?       // "09:00" or nil for all-day
    var note: String
    var isRecurring: Bool
    var recurringDays: Int?      // e.g. 1=daily, 7=weekly
    var createdAt: Date

    init(
        id: UUID = UUID(),
        companionId: UUID? = nil,
        kindId: String,
        title: String,
        dueDate: Date = Date(),
        timeOfDay: String? = nil,
        note: String = "",
        isRecurring: Bool = false,
        recurringDays: Int? = nil,
        createdAt: Date = Date()
    ) {
        self.id = id
        self.companionId = companionId
        self.kindId = kindId
        self.title = title
        self.dueDate = dueDate
        self.timeOfDay = timeOfDay
        self.note = note
        self.isRecurring = isRecurring
        self.recurringDays = recurringDays
        self.createdAt = createdAt
    }

    /// Returns true if this reminder applies to the given date
    func appliesTo(date: Date) -> Bool {
        let cal = Calendar.current
        let reminderDay = cal.startOfDay(for: dueDate)
        let targetDay = cal.startOfDay(for: date)

        if !isRecurring {
            return reminderDay == targetDay
        }

        guard let interval = recurringDays, interval > 0 else { return reminderDay == targetDay }

        // Yearly: match month and day
        if interval == 365 {
            return cal.component(.month, from: reminderDay) == cal.component(.month, from: targetDay)
                && cal.component(.day, from: reminderDay) == cal.component(.day, from: targetDay)
        }

        guard let days = cal.dateComponents([.day], from: reminderDay, to: targetDay).day else { return false }
        return days >= 0 && days % interval == 0
    }
}

extension CareReminder {
    init(from decoder: Decoder) throws {
        let c = try decoder.container(keyedBy: CodingKeys.self)
        id = try c.decode(UUID.self, forKey: .id)
        companionId = try c.decodeIfPresent(UUID.self, forKey: .companionId)
        if let kindId = try c.decodeIfPresent(String.self, forKey: .kindId) {
            self.kindId = kindId
        } else if let kind = try c.decodeIfPresent(CareReminderKind.self, forKey: .kind) {
            self.kindId = kind.rawValue
        } else {
            self.kindId = CareReminderKind.pills.rawValue
        }
        title = try c.decode(String.self, forKey: .title)
        dueDate = try c.decode(Date.self, forKey: .dueDate)
        timeOfDay = try c.decodeIfPresent(String.self, forKey: .timeOfDay)
        note = try c.decodeIfPresent(String.self, forKey: .note) ?? ""
        isRecurring = try c.decodeIfPresent(Bool.self, forKey: .isRecurring) ?? false
        recurringDays = try c.decodeIfPresent(Int.self, forKey: .recurringDays)
        createdAt = try c.decodeIfPresent(Date.self, forKey: .createdAt) ?? Date()
    }

    func encode(to encoder: Encoder) throws {
        var c = encoder.container(keyedBy: CodingKeys.self)
        try c.encode(id, forKey: .id)
        try c.encodeIfPresent(companionId, forKey: .companionId)
        try c.encode(kindId, forKey: .kindId)
        try c.encode(title, forKey: .title)
        try c.encode(dueDate, forKey: .dueDate)
        try c.encodeIfPresent(timeOfDay, forKey: .timeOfDay)
        try c.encode(note, forKey: .note)
        try c.encode(isRecurring, forKey: .isRecurring)
        try c.encodeIfPresent(recurringDays, forKey: .recurringDays)
        try c.encode(createdAt, forKey: .createdAt)
    }

    private enum CodingKeys: String, CodingKey {
        case id, companionId, kindId, kind, title, dueDate, timeOfDay, note, isRecurring, recurringDays, createdAt
    }
}

// MARK: - Vet Visit

struct VetVisit: Codable, Identifiable, Equatable {
    let id: UUID
    var companionId: UUID
    var date: Date
    var vetName: String
    var reason: String
    var notes: String
    var createdAt: Date

    init(
        id: UUID = UUID(),
        companionId: UUID,
        date: Date = Date(),
        vetName: String = "",
        reason: String = "",
        notes: String = "",
        createdAt: Date = Date()
    ) {
        self.id = id
        self.companionId = companionId
        self.date = date
        self.vetName = vetName
        self.reason = reason
        self.notes = notes
        self.createdAt = createdAt
    }
}
