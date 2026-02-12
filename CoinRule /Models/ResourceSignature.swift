//
//  ResourceSignature.swift
//  PULSE
//
//  Resource Signature - User's unique energy pattern
//

import UIKit

struct ResourceSignature: Codable {
    let points: [CGPoint]
    let generatedDate: Date
    
    enum SignatureType {
        case sprinter    // Резкие пики
        case keeper      // Ровный
        case drifter     // Хаотичный
        case burner      // Часто на пределе
        
        var displayName: String {
            switch self {
            case .sprinter: return "The Sprinter"
            case .keeper: return "The Keeper"
            case .drifter: return "The Drifter"
            case .burner: return "The Burner"
            }
        }
        
        var description: String {
            switch self {
            case .sprinter: return "Sharp peaks, quick recoveries"
            case .keeper: return "Steady and stable rhythm"
            case .drifter: return "Flowing without overload"
            case .burner: return "Often at full capacity"
            }
        }
        
        var insight: String {
            switch self {
            case .sprinter: return "Your weeks tend to start intense, then stabilize"
            case .keeper: return "You maintain consistent energy across days"
            case .drifter: return "You adapt naturally to changing demands"
            case .burner: return "You push hard but remember to rest"
            }
        }
    }
    
    static func generate(from records: [DailyPulseRecord]) -> ResourceSignature {
        guard !records.isEmpty else {
            return ResourceSignature(points: [], generatedDate: Date())
        }
        
        let recentRecords = Array(records.prefix(30))
        var points: [CGPoint] = []
        
        for (index, record) in recentRecords.enumerated() {
            let x = CGFloat(index) / CGFloat(max(recentRecords.count - 1, 1))
            
            // Вычисляем интенсивность дня
            let intensity = calculateIntensity(for: record)
            let y = 1.0 - intensity // Инвертируем для визуализации
            
            points.append(CGPoint(x: x, y: y))
        }
        
        return ResourceSignature(points: points, generatedDate: Date())
    }
    
    private static func calculateIntensity(for record: DailyPulseRecord) -> CGFloat {
        guard !record.beats.isEmpty else { return 0.5 }
        
        let expensiveMoods = record.beats.filter { $0.mood == .expensive }.count
        let cheapMoods = record.beats.filter { $0.mood == .cheap }.count
        let totalBeats = record.beats.count
        
        let intensityScore = (CGFloat(expensiveMoods) * 1.0 + CGFloat(cheapMoods) * 0.0) / CGFloat(totalBeats)
        return intensityScore
    }
    
    static func detectArchetype(from records: [DailyPulseRecord]) -> SignatureType {
        guard records.count >= 7 else { return .keeper }
        
        let recentRecords = Array(records.prefix(14))
        var intensities: [CGFloat] = []
        
        for record in recentRecords {
            intensities.append(calculateIntensity(for: record))
        }
        
        // Анализируем паттерн
        let variance = calculateVariance(intensities)
        let averageIntensity = intensities.reduce(0, +) / CGFloat(intensities.count)
        let peakCount = countPeaks(intensities)
        
        if averageIntensity > 0.7 {
            return .burner
        } else if variance > 0.15 && peakCount > 3 {
            return .sprinter
        } else if variance < 0.05 {
            return .keeper
        } else {
            return .drifter
        }
    }
    
    private static func calculateVariance(_ values: [CGFloat]) -> CGFloat {
        let mean = values.reduce(0, +) / CGFloat(values.count)
        let squaredDiffs = values.map { pow($0 - mean, 2) }
        return squaredDiffs.reduce(0, +) / CGFloat(values.count)
    }
    
    private static func countPeaks(_ values: [CGFloat]) -> Int {
        var peaks = 0
        for i in 1..<values.count-1 {
            if values[i] > values[i-1] && values[i] > values[i+1] && values[i] > 0.6 {
                peaks += 1
            }
        }
        return peaks
    }
}

struct QuietWin: Codable, Identifiable {
    let id: UUID
    let title: String
    let date: Date
    let type: WinType
    
    enum WinType: String, Codable {
        case calmStreak
        case recovery
        case balancedWeek
        case consistency
        
        var emoji: String {
            switch self {
            case .calmStreak: return "🌊"
            case .recovery: return "🌱"
            case .balancedWeek: return "⚖️"
            case .consistency: return "✨"
            }
        }
    }
    
    init(title: String, type: WinType) {
        self.id = UUID()
        self.title = title
        self.date = Date()
        self.type = type
    }
}

struct PersonalBaseline: Codable {
    let calmDayAverage: Int
    let neutralDayAverage: Int
    let intenseDayAverage: Int
    let calculatedDate: Date
    
    static func calculate(from records: [DailyPulseRecord]) -> PersonalBaseline {
        let recentRecords = Array(records.prefix(30))
        
        var calmDays: [Int] = []
        var neutralDays: [Int] = []
        var intenseDays: [Int] = []
        
        for record in recentRecords {
            let cheapCount = record.beats.filter { $0.mood == .cheap }.count
            let normalCount = record.beats.filter { $0.mood == .normal }.count
            let expensiveCount = record.beats.filter { $0.mood == .expensive }.count
            
            if cheapCount > normalCount && cheapCount > expensiveCount {
                calmDays.append(record.beats.count)
            } else if expensiveCount > normalCount && expensiveCount > cheapCount {
                intenseDays.append(record.beats.count)
            } else {
                neutralDays.append(record.beats.count)
            }
        }
        
        return PersonalBaseline(
            calmDayAverage: calmDays.isEmpty ? 0 : calmDays.reduce(0, +) / calmDays.count,
            neutralDayAverage: neutralDays.isEmpty ? 0 : neutralDays.reduce(0, +) / neutralDays.count,
            intenseDayAverage: intenseDays.isEmpty ? 0 : intenseDays.reduce(0, +) / intenseDays.count,
            calculatedDate: Date()
        )
    }
}
