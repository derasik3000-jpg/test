import Foundation

class InitiateVaporFlowCeremony {
    private let vaporArchive: VaporFlowArchiveProtocol
    
    init(vaporArchive: VaporFlowArchiveProtocol) {
        self.vaporArchive = vaporArchive
    }
    
    func performRitual(category: BreathFlowCategory, soundActivated: Bool) -> VaporFlowPrism {
        let prism = VaporFlowPrism(
            rhythmCategory: category.rawValue,
            durationPhase: category.phaseLength,
            soundActivated: soundActivated
        )
        
        vaporArchive.appendQuantum(prism)
        return prism
    }
}

