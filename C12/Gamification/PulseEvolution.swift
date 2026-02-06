//
//  PulseEvolution.swift
//  PULSE
//
//  Gamification - Pulse Evolution System
//

import Foundation

struct PulseEvolution {
    
    // MARK: - Evolution Levels
    
    enum Level: Int {
        case spark = 1
        case glow = 2
        case radiance = 3
        case aurora = 4
        case cosmos = 5
        
        var displayName: String {
            switch self {
            case .spark: return "Spark"
            case .glow: return "Glow"
            case .radiance: return "Radiance"
            case .aurora: return "Aurora"
            case .cosmos: return "Cosmos"
            }
        }
        
        var requiredStreak: Int {
            switch self {
            case .spark: return 0
            case .glow: return 3
            case .radiance: return 7
            case .aurora: return 14
            case .cosmos: return 30
            }
        }
        
        var description: String {
            switch self {
            case .spark: return "Your journey begins"
            case .glow: return "A steady rhythm emerges"
            case .radiance: return "Your pulse shines bright"
            case .aurora: return "Consistency becomes beauty"
            case .cosmos: return "You've reached the stars"
            }
        }
    }
    
    // MARK: - Calculate Level
    
    static func calculateLevel(streak: Int) -> Level {
        if streak >= Level.cosmos.requiredStreak {
            return .cosmos
        } else if streak >= Level.aurora.requiredStreak {
            return .aurora
        } else if streak >= Level.radiance.requiredStreak {
            return .radiance
        } else if streak >= Level.glow.requiredStreak {
            return .glow
        } else {
            return .spark
        }
    }
    
    // MARK: - Progress to Next Level
    
    static func progressToNextLevel(streak: Int) -> (current: Level, next: Level?, progress: Float) {
        let currentLevel = calculateLevel(streak: streak)
        
        guard let nextLevelRaw = Level(rawValue: currentLevel.rawValue + 1) else {
            return (currentLevel, nil, 1.0)
        }
        
        let currentThreshold = currentLevel.requiredStreak
        let nextThreshold = nextLevelRaw.requiredStreak
        let progress = Float(streak - currentThreshold) / Float(nextThreshold - currentThreshold)
        
        return (currentLevel, nextLevelRaw, min(progress, 1.0))
    }
    
    // MARK: - Hidden Forms
    
    enum HiddenForm: String, CaseIterable {
        case wave
        case spiral
        case constellation
        case infinity
        case mandala
        
        var displayName: String {
            rawValue.capitalized
        }
        
        var unlockStreak: Int {
            switch self {
            case .wave: return 5
            case .spiral: return 10
            case .constellation: return 15
            case .infinity: return 21
            case .mandala: return 30
            }
        }
        
        var description: String {
            switch self {
            case .wave: return "Flowing like water"
            case .spiral: return "Growing outward"
            case .constellation: return "Connected points of light"
            case .infinity: return "Endless continuation"
            case .mandala: return "Perfect symmetry"
            }
        }
    }
    
    static func unlockedForms(streak: Int) -> [HiddenForm] {
        return HiddenForm.allCases.filter { $0.unlockStreak <= streak }
    }
    
    static func nextFormToUnlock(streak: Int) -> HiddenForm? {
        return HiddenForm.allCases.first { $0.unlockStreak > streak }
    }
}
