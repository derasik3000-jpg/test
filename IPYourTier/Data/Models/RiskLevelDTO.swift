import Foundation
import SwiftUI

public enum RiskLevelDTO: Int, CaseIterable {
    case lowRisk = 0
    case mediumRisk = 1
    case highRisk = 2
    case redFlagCritical = 3
    
    public var displayName: String {
        switch self {
        case .lowRisk: return "Low Risk"
        case .mediumRisk: return "Moderate Risk"
        case .highRisk: return "High Risk"
        case .redFlagCritical: return "Red Flag"
        }
    }
    
    public var shortName: String {
        switch self {
        case .lowRisk: return "Low"
        case .mediumRisk: return "Moderate"
        case .highRisk: return "High"
        case .redFlagCritical: return "Red Flag"
        }
    }
    
    public var colorOpacity: Double {
        switch self {
        case .lowRisk: return 0.55
        case .mediumRisk: return 0.70
        case .highRisk: return 0.85
        case .redFlagCritical: return 1.0
        }
    }
    
    public var iconName: String {
        switch self {
        case .lowRisk: return "checkmark.circle"
        case .mediumRisk: return "exclamationmark.circle"
        case .highRisk: return "exclamationmark.octagon"
        case .redFlagCritical: return "exclamationmark.octagon.fill"
        }
    }
}

