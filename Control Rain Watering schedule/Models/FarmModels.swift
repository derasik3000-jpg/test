//
//  FarmModels.swift
//  Control Rain Watering schedule
//
//  Created by Евгений on 04.02.2026.
//

import Foundation

// MARK: - Irrigation Plot (Field Zone)

struct IrrigationPlot: Codable, Identifiable {
    let id: UUID
    var plotName: String
    var cropType: String
    var irrigationType: IrrigationType
    var soilCondition: SoilCondition
    var lastWateredDate: Date?
    var wateringSchedule: [WateringSession]
    var totalWaterUsed: Double // in liters
    var createdAt: Date
    var isArchived: Bool
    
    init(id: UUID = UUID(),
         plotName: String,
         cropType: String,
         irrigationType: IrrigationType,
         soilCondition: SoilCondition = .moist,
         lastWateredDate: Date? = nil,
         wateringSchedule: [WateringSession] = [],
         totalWaterUsed: Double = 0,
         createdAt: Date = Date(),
         isArchived: Bool = false) {
        self.id = id
        self.plotName = plotName
        self.cropType = cropType
        self.irrigationType = irrigationType
        self.soilCondition = soilCondition
        self.lastWateredDate = lastWateredDate
        self.wateringSchedule = wateringSchedule
        self.totalWaterUsed = totalWaterUsed
        self.createdAt = createdAt
        self.isArchived = isArchived
    }
}

// MARK: - Watering Session

struct WateringSession: Codable, Identifiable {
    let id: UUID
    let plotId: UUID
    let date: Date
    let durationMinutes: Int
    let waterAmount: Double // liters
    let notes: String?
    let wasRainfall: Bool
    
    init(id: UUID = UUID(),
         plotId: UUID,
         date: Date = Date(),
         durationMinutes: Int,
         waterAmount: Double,
         notes: String? = nil,
         wasRainfall: Bool = false) {
        self.id = id
        self.plotId = plotId
        self.date = date
        self.durationMinutes = durationMinutes
        self.waterAmount = waterAmount
        self.notes = notes
        self.wasRainfall = wasRainfall
    }
}

// MARK: - Irrigation Type

enum IrrigationType: String, Codable, CaseIterable {
    case drip = "Drip"
    case sprinkler = "Sprinkler"
    case flood = "Flood"
    case manual = "Manual"
    
    var emoji: String {
        switch self {
        case .drip: return "💧"
        case .sprinkler: return "🚿"
        case .flood: return "🌊"
        case .manual: return "🪣"
        }
    }
}

// MARK: - Soil Condition

enum SoilCondition: String, Codable, CaseIterable {
    case dry = "Dry"
    case moist = "Moist"
    case wet = "Wet"
    case saturated = "Saturated"
    
    var emoji: String {
        switch self {
        case .dry: return "🏜️"
        case .moist: return "🌱"
        case .wet: return "💦"
        case .saturated: return "🌊"
        }
    }
}

// MARK: - Farmer Profile (Gamification)

struct FarmerProfile: Codable {
    var farmerName: String
    var avatarEmoji: String
    var experiencePoints: Int
    var level: Int
    var currentStreak: Int
    var longestStreak: Int
    var achievements: [Achievement]
    var totalPlotsManaged: Int
    var totalWaterSaved: Double
    var joinedDate: Date
    
    init(farmerName: String = "Farmer",
         avatarEmoji: String = "👨‍🌾",
         experiencePoints: Int = 0,
         level: Int = 1,
         currentStreak: Int = 0,
         longestStreak: Int = 0,
         achievements: [Achievement] = [],
         totalPlotsManaged: Int = 0,
         totalWaterSaved: Double = 0,
         joinedDate: Date = Date()) {
        self.farmerName = farmerName
        self.avatarEmoji = avatarEmoji
        self.experiencePoints = experiencePoints
        self.level = level
        self.currentStreak = currentStreak
        self.longestStreak = longestStreak
        self.achievements = achievements
        self.totalPlotsManaged = totalPlotsManaged
        self.totalWaterSaved = totalWaterSaved
        self.joinedDate = joinedDate
    }
    
    mutating func addExperience(_ points: Int) {
        experiencePoints += points
        level = calculateLevel()
    }
    
    private func calculateLevel() -> Int {
        return (experiencePoints / 100) + 1
    }
}

// MARK: - Achievement

struct Achievement: Codable, Identifiable {
    let id: UUID
    let title: String
    let description: String
    let emoji: String
    let unlockedDate: Date?
    let isUnlocked: Bool
    
    init(id: UUID = UUID(),
         title: String,
         description: String,
         emoji: String,
         unlockedDate: Date? = nil,
         isUnlocked: Bool = false) {
        self.id = id
        self.title = title
        self.description = description
        self.emoji = emoji
        self.unlockedDate = unlockedDate
        self.isUnlocked = isUnlocked
    }
}

// MARK: - Weather Note (Manual Entry)

struct WeatherNote: Codable, Identifiable {
    let id: UUID
    let date: Date
    let condition: WeatherCondition
    let notes: String?
    
    init(id: UUID = UUID(),
         date: Date = Date(),
         condition: WeatherCondition,
         notes: String? = nil) {
        self.id = id
        self.date = date
        self.condition = condition
        self.notes = notes
    }
}

enum WeatherCondition: String, Codable, CaseIterable {
    case sunny = "Sunny"
    case cloudy = "Cloudy"
    case rainy = "Rainy"
    case stormy = "Stormy"
    
    var emoji: String {
        switch self {
        case .sunny: return "☀️"
        case .cloudy: return "☁️"
        case .rainy: return "🌧️"
        case .stormy: return "⛈️"
        }
    }
}
