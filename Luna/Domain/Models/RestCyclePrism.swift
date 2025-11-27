import Foundation

struct RestCyclePrism: Identifiable, Codable {
    let cycleIdentifier: UUID
    let initiationMoment: Date
    let terminationMoment: Date
    let qualityMetric: Int?
    let breathFlowLinks: [UUID]
    let commentNote: String?
    
    var id: UUID { cycleIdentifier }
    
    var phaseDurationInMinutes: Double {
        terminationMoment.timeIntervalSince(initiationMoment) / 60.0
    }
    
    var sleepTimeRange: String {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        return "\(formatter.string(from: initiationMoment)) - \(formatter.string(from: terminationMoment))"
    }
    
    var qualityDescription: String {
        guard let quality = qualityMetric else { return "Not rated" }
        switch quality {
        case 1...2: return "Poor"
        case 3...4: return "Fair"
        case 5...6: return "Good"
        case 7...8: return "Very Good"
        case 9...10: return "Excellent"
        default: return "Unknown"
        }
    }
    
    init(cycleIdentifier: UUID = UUID(), initiationMoment: Date, terminationMoment: Date, qualityMetric: Int? = nil, breathFlowLinks: [UUID] = [], commentNote: String? = nil) {
        self.cycleIdentifier = cycleIdentifier
        self.initiationMoment = initiationMoment
        self.terminationMoment = terminationMoment
        self.qualityMetric = qualityMetric
        self.breathFlowLinks = breathFlowLinks
        self.commentNote = commentNote
    }
}

