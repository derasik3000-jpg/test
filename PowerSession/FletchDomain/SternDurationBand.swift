import Foundation

public enum SternDurationBand: Int, CaseIterable, Identifiable {
    case short = 0
    case medium = 1
    case long = 2
    
    public var id: Int { rawValue }
    
    public var tarnLabel: String {
        switch self {
        case .short: return "≤20 min"
        case .medium: return "20-40 min"
        case .long: return "≥40 min"
        }
    }
    
    public var quellBitMask: Int16 {
        return 1 << Int16(rawValue)
    }
}

public extension Set where Element == SternDurationBand {
    var fizzCombinedBits: Int16 {
        reduce(0) { $0 | $1.quellBitMask }
    }
    
    static func murkyFromBits(_ bits: Int16) -> Set<SternDurationBand> {
        var result = Set<SternDurationBand>()
        for band in SternDurationBand.allCases {
            if bits & band.quellBitMask != 0 {
                result.insert(band)
            }
        }
        return result
    }
}

