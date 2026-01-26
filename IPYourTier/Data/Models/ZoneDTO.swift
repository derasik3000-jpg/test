import Foundation

public enum ZoneDTO: Int, CaseIterable, Identifiable {
    case neckRegion = 0
    case backSpinal = 1
    case shoulderJoint = 2
    case elbowArea = 3
    case wristHand = 4
    case hipPelvis = 5
    case kneeJoint = 6
    case shinCalf = 7
    case footAnkle = 8
    case otherArea = 9
    
    public var id: Int { rawValue }
    
    public var displayName: String {
        switch self {
        case .neckRegion: return "Neck"
        case .backSpinal: return "Back"
        case .shoulderJoint: return "Shoulder"
        case .elbowArea: return "Elbow"
        case .wristHand: return "Wrist"
        case .hipPelvis: return "Hip"
        case .kneeJoint: return "Knee"
        case .shinCalf: return "Shin"
        case .footAnkle: return "Foot"
        case .otherArea: return "Other"
        }
    }
    
    public var iconName: String {
        switch self {
        case .neckRegion: return "figure.stand"
        case .backSpinal: return "figure.walk"
        case .shoulderJoint: return "figure.arms.open"
        case .elbowArea: return "hand.raised"
        case .wristHand: return "hand.point.up"
        case .hipPelvis: return "figure.walk.motion"
        case .kneeJoint: return "figure.run"
        case .shinCalf: return "figure.climbing"
        case .footAnkle: return "shoeprints.fill"
        case .otherArea: return "cross.circle"
        }
    }
}

