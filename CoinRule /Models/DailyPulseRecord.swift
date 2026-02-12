//
//  DailyPulseRecord.swift
//  Travel Budget Tracker
//
//  Data Model - Daily Travel Expenses
//

import Foundation

struct DailyPulseRecord: Codable {
    let id: UUID
    let date: Date
    var beats: [Beat]
    var streakCount: Int
    var pulseEvolutionLevel: Int
    
    init(date: Date = Date()) {
        self.id = UUID()
        self.date = date
        self.beats = []
        self.streakCount = 0
        self.pulseEvolutionLevel = 1
    }
    
    mutating func addBeat(_ beat: Beat) {
        beats.append(beat)
    }
    
    // Computed property for total daily spending
    var totalAmount: Double {
        return beats.reduce(0) { $0 + $1.amount }
    }
}

struct Beat: Codable {
    let id: UUID
    let timestamp: Date
    let mood: Mood
    let note: String?
    let amount: Double
    let category: ExpenseCategory
    let currency: String
    
    init(mood: Mood, note: String? = nil, amount: Double = 0.0, category: ExpenseCategory = .other, currency: String = "USD") {
        self.id = UUID()
        self.timestamp = Date()
        self.mood = mood
        self.note = note
        self.amount = amount
        self.category = category
        self.currency = currency
    }
}

enum Mood: String, Codable, CaseIterable {
    case expensive  // Дорого
    case normal     // Нормально
    case cheap      // Дёшево
    
    var displayName: String {
        switch self {
        case .expensive: return "Expensive"
        case .normal: return "Normal"
        case .cheap: return "Cheap"
        }
    }
    
    var emoji: String {
        switch self {
        case .expensive: return "💸"
        case .normal: return "💰"
        case .cheap: return "💵"
        }
    }
}

enum ExpenseCategory: String, Codable, CaseIterable {
    case food           // Еда
    case transport      // Транспорт
    case accommodation  // Жильё
    case entertainment  // Развлечения
    case shopping       // Покупки
    case health         // Здоровье
    case other          // Другое
    
    var displayName: String {
        switch self {
        case .food: return "Food"
        case .transport: return "Transport"
        case .accommodation: return "Accommodation"
        case .entertainment: return "Entertainment"
        case .shopping: return "Shopping"
        case .health: return "Health"
        case .other: return "Other"
        }
    }
    
    var emoji: String {
        switch self {
        case .food: return "🍽️"
        case .transport: return "🚗"
        case .accommodation: return "🏨"
        case .entertainment: return "🎭"
        case .shopping: return "🛍️"
        case .health: return "💊"
        case .other: return "📦"
        }
    }
    
    var color: String {
        switch self {
        case .food: return "pulseCalm"
        case .transport: return "pulsePrimary"
        case .accommodation: return "pulseIntense"
        case .entertainment: return "pulseCalm"
        case .shopping: return "pulsePrimary"
        case .health: return "pulseIntense"
        case .other: return "pulseNeutral"
        }
    }
}
