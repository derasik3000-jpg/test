//
//  PulseStorage.swift
//  PULSE
//
//  Local Storage Manager
//

import Foundation

class PulseStorage {
    
    static let shared = PulseStorage()
    
    private let fileManager = FileManager.default
    private let encoder = JSONEncoder()
    private let decoder = JSONDecoder()
    
    private init() {
        encoder.dateEncodingStrategy = .iso8601
        decoder.dateDecodingStrategy = .iso8601
    }
    
    // MARK: - File URLs
    
    private var documentsDirectory: URL {
        fileManager.urls(for: .documentDirectory, in: .userDomainMask)[0]
    }
    
    private var recordsURL: URL {
        documentsDirectory.appendingPathComponent("pulse_records.json")
    }
    
    private var notesURL: URL {
        documentsDirectory.appendingPathComponent("moment_notes.json")
    }
    
    private var avatarURL: URL {
        documentsDirectory.appendingPathComponent("avatar_glyph.json")
    }
    
    private var customCategoriesURL: URL {
        documentsDirectory.appendingPathComponent("custom_categories.json")
    }
    
    private var tripBudgetURL: URL {
        documentsDirectory.appendingPathComponent("trip_budget.json")
    }
    
    // MARK: - Daily Pulse Records
    
    func saveDailyRecord(_ record: DailyPulseRecord) {
        var records = loadAllRecords()
        
        if let index = records.firstIndex(where: { Calendar.current.isDate($0.date, inSameDayAs: record.date) }) {
            records[index] = record
        } else {
            records.append(record)
        }
        
        saveRecords(records)
    }
    
    func loadTodayRecord() -> DailyPulseRecord {
        let records = loadAllRecords()
        let today = Date()
        
        if let todayRecord = records.first(where: { Calendar.current.isDate($0.date, inSameDayAs: today) }) {
            return todayRecord
        } else {
            return DailyPulseRecord(date: today)
        }
    }
    
    func loadAllRecords() -> [DailyPulseRecord] {
        guard let data = try? Data(contentsOf: recordsURL),
              let records = try? decoder.decode([DailyPulseRecord].self, from: data) else {
            return []
        }
        return records.sorted { $0.date > $1.date }
    }
    
    private func saveRecords(_ records: [DailyPulseRecord]) {
        guard let data = try? encoder.encode(records) else { return }
        try? data.write(to: recordsURL)
    }
    
    // MARK: - Moment Notes
    
    func saveNote(_ note: MomentNote) {
        var notes = loadAllNotes()
        notes.append(note)
        
        guard let data = try? encoder.encode(notes) else { return }
        try? data.write(to: notesURL)
    }
    
    func loadAllNotes() -> [MomentNote] {
        guard let data = try? Data(contentsOf: notesURL),
              let notes = try? decoder.decode([MomentNote].self, from: data) else {
            return []
        }
        return notes.sorted { $0.timestamp > $1.timestamp }
    }
    
    // MARK: - Avatar
    
    func saveAvatar(_ avatar: AvatarGlyph) {
        guard let data = try? encoder.encode(avatar) else { return }
        try? data.write(to: avatarURL)
    }
    
    func loadAvatar() -> AvatarGlyph {
        guard let data = try? Data(contentsOf: avatarURL),
              let avatar = try? decoder.decode(AvatarGlyph.self, from: data) else {
            return AvatarGlyph()
        }
        return avatar
    }
    
    // MARK: - Custom Categories
    
    func saveCustomCategories(_ categories: [CustomCategory]) {
        guard let data = try? encoder.encode(categories) else { return }
        try? data.write(to: customCategoriesURL)
    }
    
    func loadCustomCategories() -> [CustomCategory] {
        guard let data = try? Data(contentsOf: customCategoriesURL),
              let categories = try? decoder.decode([CustomCategory].self, from: data) else {
            return []
        }
        return categories
    }
    
    func addCustomCategory(_ category: CustomCategory) {
        var categories = loadCustomCategories()
        categories.append(category)
        saveCustomCategories(categories)
    }
    
    func deleteCustomCategory(id: UUID) {
        var categories = loadCustomCategories()
        categories.removeAll { $0.id == id }
        saveCustomCategories(categories)
    }
    
    // MARK: - Trip Budget
    
    func saveTripBudget(_ budget: TripBudget) {
        guard let data = try? encoder.encode(budget) else { return }
        try? data.write(to: tripBudgetURL)
    }
    
    func loadTripBudget() -> TripBudget? {
        guard let data = try? Data(contentsOf: tripBudgetURL),
              let budget = try? decoder.decode(TripBudget.self, from: data) else {
            return nil
        }
        return budget
    }
    
    func deleteTripBudget() {
        try? FileManager.default.removeItem(at: tripBudgetURL)
    }
    
    // MARK: - Streak Calculation
    
    func calculateStreak() -> Int {
        let records = loadAllRecords()
        guard !records.isEmpty else { return 0 }
        
        var streak = 0
        var currentDate = Date()
        
        for record in records {
            if Calendar.current.isDate(record.date, inSameDayAs: currentDate) {
                streak += 1
                currentDate = Calendar.current.date(byAdding: .day, value: -1, to: currentDate) ?? currentDate
            } else {
                break
            }
        }
        
        return streak
    }
}

// MARK: - Custom Category Model

struct CustomCategory: Codable, Identifiable {
    let id: UUID
    let name: String
    let emoji: String
    
    init(name: String, emoji: String) {
        self.id = UUID()
        self.name = name
        self.emoji = emoji
    }
}

// MARK: - Trip Budget Model

struct TripBudget: Codable {
    let id: UUID
    let totalAmount: Double
    let currency: String
    let startDate: Date
    let endDate: Date?
    let tripName: String
    
    init(totalAmount: Double, currency: String = "USD", startDate: Date = Date(), endDate: Date? = nil, tripName: String = "My Trip") {
        self.id = UUID()
        self.totalAmount = totalAmount
        self.currency = currency
        self.startDate = startDate
        self.endDate = endDate
        self.tripName = tripName
    }
}
