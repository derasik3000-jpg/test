import Foundation

struct VaporFlowPrism: Identifiable, Codable {
    let flowIdentifier: UUID
    let rhythmCategory: String
    let durationPhase: Int
    let chronoStamp: Date
    let soundActivated: Bool
    
    var id: UUID { flowIdentifier }
    
    init(flowIdentifier: UUID = UUID(), rhythmCategory: String, durationPhase: Int, chronoStamp: Date = Date(), soundActivated: Bool = false) {
        self.flowIdentifier = flowIdentifier
        self.rhythmCategory = rhythmCategory
        self.durationPhase = durationPhase
        self.chronoStamp = chronoStamp
        self.soundActivated = soundActivated
    }
}

enum BreathFlowCategory: String, CaseIterable {
    case swiftRelief = "short"
    case deepSerenity = "deep"
    case tranquilEssence = "relax"
    
    var displayNomenclature: String {
        switch self {
        case .swiftRelief: return "Quick Relief"
        case .deepSerenity: return "Deep Sleep"
        case .tranquilEssence: return "Relaxation"
        }
    }
    
    var phaseLength: Int {
        switch self {
        case .swiftRelief: return 3
        case .deepSerenity: return 10
        case .tranquilEssence: return 7
        }
    }
}

