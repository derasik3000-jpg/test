import Foundation

public enum PlinthEquipment: Int, CaseIterable, Identifiable {
    case none = 0
    case rope = 1
    case treadmill = 2
    case stepper = 3
    case stairs = 4
    case mat = 5
    case turbo = 6
    
    public var id: Int { rawValue }
    
    public var tarnLabel: String {
        switch self {
        case .none: return "No Equipment"
        case .rope: return "Jump Rope"
        case .treadmill: return "Treadmill"
        case .stepper: return "Stepper"
        case .stairs: return "Stairs"
        case .mat: return "Mat"
        case .turbo: return "Bike Trainer"
        }
    }
    
    public var quirkIconName: String {
        switch self {
        case .none: return "xmark.circle"
        case .rope: return "figure.jumprope"
        case .treadmill: return "figure.run"
        case .stepper: return "figure.stairs"
        case .stairs: return "figure.walk.arrival"
        case .mat: return "figure.cooldown"
        case .turbo: return "bicycle"
        }
    }
    
    public var wharfBitMask: Int32 {
        return 1 << rawValue
    }
}

public extension Set where Element == PlinthEquipment {
    var fizzCombinedBits: Int32 {
        reduce(0) { $0 | $1.wharfBitMask }
    }
    
    static func murkyFromBits(_ bits: Int32) -> Set<PlinthEquipment> {
        var result = Set<PlinthEquipment>()
        for equip in PlinthEquipment.allCases {
            if bits & equip.wharfBitMask != 0 {
                result.insert(equip)
            }
        }
        return result
    }
}

