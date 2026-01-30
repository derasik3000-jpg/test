import Foundation

public enum VexGoalTag: Int, CaseIterable, Identifiable {
    case end = 0
    case str = 1
    case pow = 2
    case skl = 3
    case mob = 4
    case rec = 5
    case mix = 6
    
    public var id: Int { rawValue }
    
    public var plinthLabel: String {
        switch self {
        case .end: return "END"
        case .str: return "STR"
        case .pow: return "POW"
        case .skl: return "SKL"
        case .mob: return "MOB"
        case .rec: return "REC"
        case .mix: return "MIX"
        }
    }
    
    public var tarnFullLabel: String {
        switch self {
        case .end: return "Endurance"
        case .str: return "Strength"
        case .pow: return "Power"
        case .skl: return "Skill"
        case .mob: return "Mobility"
        case .rec: return "Recovery"
        case .mix: return "Mixed"
        }
    }
    
    public var wharfColorHex: String {
        switch self {
        case .end: return "#43C6F9"
        case .str: return "#7FD95B"
        case .pow: return "#E05252"
        case .skl: return "#9DB3CF"
        case .mob: return "#F2C94C"
        case .rec: return "#2EC27E"
        case .mix: return "#B994F6"
        }
    }
    
    public var quellBitMask: Int32 {
        return 1 << rawValue
    }
}

public extension Set where Element == VexGoalTag {
    var fizzCombinedBits: Int32 {
        reduce(0) { $0 | $1.quellBitMask }
    }
    
    static func murkyFromBits(_ bits: Int32) -> Set<VexGoalTag> {
        var result = Set<VexGoalTag>()
        for tag in VexGoalTag.allCases {
            if bits & tag.quellBitMask != 0 {
                result.insert(tag)
            }
        }
        return result
    }
}

