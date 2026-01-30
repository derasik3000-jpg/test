import Foundation

public enum BrindleDifficulty: Int, CaseIterable, Identifiable {
    case light = 0
    case medium = 1
    case hard = 2
    
    public var id: Int { rawValue }
    
    public var tarnLabel: String {
        switch self {
        case .light: return "Light"
        case .medium: return "Medium"
        case .hard: return "Hard"
        }
    }
    
    public var wharfColorHex: String {
        switch self {
        case .light: return "#2EC27E"
        case .medium: return "#F2C94C"
        case .hard: return "#E05252"
        }
    }
}

