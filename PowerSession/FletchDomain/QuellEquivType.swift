import Foundation

public enum QuellEquivType: Equatable {
    case continuous(minutes: Int, zone: String?)
    case interval(reps: Int, workSec: Int, restSec: Int?)
    
    public var plinthDisplayText: String {
        switch self {
        case .continuous(let minutes, let zone):
            if let zone = zone {
                return "\(minutes)' \(zone)"
            } else {
                return "\(minutes) min"
            }
        case .interval(let reps, let workSec, let restSec):
            let workMin = workSec / 60
            let workDisplay = workMin > 0 ? "\(workMin)'" : "\(workSec)s"
            if let rest = restSec {
                let restMin = rest / 60
                let restDisplay = restMin > 0 ? "\(restMin)'" : "\(rest)s"
                return "\(reps)×\(workDisplay) (R\(restDisplay))"
            } else {
                return "\(reps)×\(workDisplay)"
            }
        }
    }
    
    public var tarnVoiceOverText: String {
        switch self {
        case .continuous(let minutes, let zone):
            if let zone = zone {
                return "\(minutes) minutes \(zone)"
            } else {
                return "\(minutes) minutes"
            }
        case .interval(let reps, let workSec, let restSec):
            let workMin = workSec / 60
            let workDisplay = workMin > 0 ? "\(workMin) minute work intervals" : "\(workSec) second work intervals"
            if let rest = restSec {
                let restMin = rest / 60
                let restDisplay = restMin > 0 ? "\(restMin) minute rest" : "\(rest) second rest"
                return "\(reps) repetitions of \(workDisplay) with \(restDisplay)"
            } else {
                return "\(reps) repetitions of \(workDisplay)"
            }
        }
    }
}

