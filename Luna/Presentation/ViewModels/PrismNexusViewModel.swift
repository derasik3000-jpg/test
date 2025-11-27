import Foundation
import Combine

class PrismNexusViewModel: ObservableObject {
    @Published var recommendedFlow: BreathFlowCategory = .tranquilEssence
    @Published var recentSessions: [VaporFlowPrism] = []
    @Published var greetingPhrase: String = "Ready for a peaceful night?"
    
    private let vaporArchive: VaporFlowArchiveProtocol
    private let cycleArchive: RestCycleArchiveProtocol
    
    let availableFlows: [(category: BreathFlowCategory, title: String, subtitle: String, duration: String)] = [
        (.swiftRelief, "Quick Relief", "Perfect for fast calm", "3 min"),
        (.deepSerenity, "Deep Sleep", "Full relaxation mode", "10 min"),
        (.tranquilEssence, "Relaxation", "Gentle unwinding", "7 min")
    ]
    
    init(vaporArchive: VaporFlowArchiveProtocol, cycleArchive: RestCycleArchiveProtocol) {
        self.vaporArchive = vaporArchive
        self.cycleArchive = cycleArchive
        synthesizeRecommendations()
    }
    
    func synthesizeRecommendations() {
        recentSessions = vaporArchive.retrieveRecentQuantums(threshold: 5)
        
        let recentCycles = cycleArchive.retrieveRecentCycles(threshold: 7)
        let avgDuration = recentCycles.isEmpty ? 0 : recentCycles.map { $0.phaseDurationInMinutes }.reduce(0, +) / Double(recentCycles.count)
        
        if avgDuration < 360 {
            recommendedFlow = .deepSerenity
            greetingPhrase = "Let's aim for deeper rest tonight"
        } else if avgDuration > 480 {
            recommendedFlow = .swiftRelief
            greetingPhrase = "A quick session to maintain balance"
        } else {
            recommendedFlow = .tranquilEssence
            greetingPhrase = "Ready for a peaceful night?"
        }
    }
}

