//
//  BarnStorageManager.swift
//  Control Rain Watering schedule
//
//  Created by Евгений on 04.02.2026.
//

import Foundation

/// Local storage manager using UserDefaults and FileManager
final class BarnStorageManager {
    
    static let shared = BarnStorageManager()
    
    private let defaults = UserDefaults.standard
    private let fileManager = FileManager.default
    
    // MARK: - Storage Keys
    
    private enum StorageKey {
        static let isFirstLaunch = "barn_first_launch"
        static let onboardingComplete = "barn_onboarding_complete"
        static let farmerProfile = "barn_farmer_profile"
        static let irrigationPlots = "barn_irrigation_plots"
        static let wateringSessions = "barn_watering_sessions"
        static let weatherNotes = "barn_weather_notes"
        static let lastOpenDate = "barn_last_open_date"
    }
    
    private init() {}
    
    // MARK: - First Launch
    
    func isFirstLaunch() -> Bool {
        if defaults.object(forKey: StorageKey.isFirstLaunch) == nil {
            defaults.set(true, forKey: StorageKey.isFirstLaunch)
            return true
        }
        return false
    }
    
    func markOnboardingComplete() {
        defaults.set(true, forKey: StorageKey.onboardingComplete)
    }
    
    func isOnboardingComplete() -> Bool {
        return defaults.bool(forKey: StorageKey.onboardingComplete)
    }
    
    // MARK: - Farmer Profile
    
    func saveFarmerProfile(_ profile: FarmerProfile) {
        if let encoded = try? JSONEncoder().encode(profile) {
            defaults.set(encoded, forKey: StorageKey.farmerProfile)
        }
    }
    
    func loadFarmerProfile() -> FarmerProfile {
        if let data = defaults.data(forKey: StorageKey.farmerProfile),
           let profile = try? JSONDecoder().decode(FarmerProfile.self, from: data) {
            return profile
        }
        return FarmerProfile()
    }
    
    // MARK: - Irrigation Plots
    
    func savePlots(_ plots: [IrrigationPlot]) {
        if let encoded = try? JSONEncoder().encode(plots) {
            defaults.set(encoded, forKey: StorageKey.irrigationPlots)
        }
    }
    
    func loadPlots() -> [IrrigationPlot] {
        if let data = defaults.data(forKey: StorageKey.irrigationPlots) {
            // Try to decode with new format (with isArchived)
            if let plots = try? JSONDecoder().decode([IrrigationPlot].self, from: data) {
                return plots
            }
            
            // Try to decode old format (without isArchived) and add default value
            let decoder = JSONDecoder()
            if let oldPlots = try? decoder.decode([OldIrrigationPlot].self, from: data) {
                let newPlots = oldPlots.map { oldPlot in
                    IrrigationPlot(
                        id: oldPlot.id,
                        plotName: oldPlot.plotName,
                        cropType: oldPlot.cropType,
                        irrigationType: oldPlot.irrigationType,
                        soilCondition: oldPlot.soilCondition,
                        lastWateredDate: oldPlot.lastWateredDate,
                        wateringSchedule: oldPlot.wateringSchedule,
                        totalWaterUsed: oldPlot.totalWaterUsed,
                        createdAt: oldPlot.createdAt,
                        isArchived: false // Default to active for old data
                    )
                }
                // Save updated format
                savePlots(newPlots)
                return newPlots
            }
        }
        return []
    }
    
    // Temporary struct for decoding old format
    private struct OldIrrigationPlot: Codable {
        let id: UUID
        var plotName: String
        var cropType: String
        var irrigationType: IrrigationType
        var soilCondition: SoilCondition
        var lastWateredDate: Date?
        var wateringSchedule: [WateringSession]
        var totalWaterUsed: Double
        var createdAt: Date
    }
    
    func loadActivePlots() -> [IrrigationPlot] {
        return loadPlots().filter { !$0.isArchived }
    }
    
    func loadArchivedPlots() -> [IrrigationPlot] {
        return loadPlots().filter { $0.isArchived }
    }
    
    func addPlot(_ plot: IrrigationPlot) {
        var plots = loadPlots()
        plots.append(plot)
        savePlots(plots)
    }
    
    func updatePlot(_ plot: IrrigationPlot) {
        var plots = loadPlots()
        if let index = plots.firstIndex(where: { $0.id == plot.id }) {
            plots[index] = plot
            savePlots(plots)
        }
    }
    
    func deletePlot(id: UUID) {
        var plots = loadPlots()
        plots.removeAll { $0.id == id }
        savePlots(plots)
    }
    
    func archivePlot(id: UUID) {
        var plots = loadPlots()
        if let index = plots.firstIndex(where: { $0.id == id }) {
            plots[index].isArchived = true
            savePlots(plots)
        }
    }
    
    func unarchivePlot(id: UUID) {
        var plots = loadPlots()
        if let index = plots.firstIndex(where: { $0.id == id }) {
            plots[index].isArchived = false
            savePlots(plots)
        }
    }
    
    // MARK: - Watering Sessions
    
    func saveSessions(_ sessions: [WateringSession]) {
        if let encoded = try? JSONEncoder().encode(sessions) {
            defaults.set(encoded, forKey: StorageKey.wateringSessions)
        }
    }
    
    func loadSessions() -> [WateringSession] {
        if let data = defaults.data(forKey: StorageKey.wateringSessions),
           let sessions = try? JSONDecoder().decode([WateringSession].self, from: data) {
            return sessions
        }
        return []
    }
    
    func addSession(_ session: WateringSession) {
        var sessions = loadSessions()
        sessions.append(session)
        saveSessions(sessions)
        
        // Update plot's last watered date
        var plots = loadPlots()
        if let index = plots.firstIndex(where: { $0.id == session.plotId }) {
            plots[index].lastWateredDate = session.date
            plots[index].totalWaterUsed += session.waterAmount
            savePlots(plots)
        }
    }
    
    func sessionsForPlot(id: UUID) -> [WateringSession] {
        return loadSessions().filter { $0.plotId == id }
    }
    
    // MARK: - Weather Notes
    
    func saveWeatherNotes(_ notes: [WeatherNote]) {
        if let encoded = try? JSONEncoder().encode(notes) {
            defaults.set(encoded, forKey: StorageKey.weatherNotes)
        }
    }
    
    func loadWeatherNotes() -> [WeatherNote] {
        if let data = defaults.data(forKey: StorageKey.weatherNotes),
           let notes = try? JSONDecoder().decode([WeatherNote].self, from: data) {
            return notes
        }
        return []
    }
    
    func addWeatherNote(_ note: WeatherNote) {
        var notes = loadWeatherNotes()
        notes.append(note)
        saveWeatherNotes(notes)
    }
    
    // MARK: - Streak Management
    
    func updateStreak() {
        var profile = loadFarmerProfile()
        let lastDate = defaults.object(forKey: StorageKey.lastOpenDate) as? Date
        let today = Calendar.current.startOfDay(for: Date())
        
        if let lastDate = lastDate {
            let lastDay = Calendar.current.startOfDay(for: lastDate)
            let daysDifference = Calendar.current.dateComponents([.day], from: lastDay, to: today).day ?? 0
            
            if daysDifference == 1 {
                // Consecutive day
                profile.currentStreak += 1
                if profile.currentStreak > profile.longestStreak {
                    profile.longestStreak = profile.currentStreak
                }
            } else if daysDifference > 1 {
                // Streak broken
                profile.currentStreak = 1
            }
        } else {
            profile.currentStreak = 1
        }
        
        defaults.set(Date(), forKey: StorageKey.lastOpenDate)
        saveFarmerProfile(profile)
    }
    
    // MARK: - Statistics
    
    func getTotalWaterUsed() -> Double {
        return loadPlots().reduce(0) { $0 + $1.totalWaterUsed }
    }
    
    func getTotalSessions() -> Int {
        return loadSessions().count
    }
    
    func getActivePlotsCount() -> Int {
        return loadActivePlots().count
    }
}
