import Foundation

class AppendRestCycleManifestation {
    private let cycleArchive: RestCycleArchiveProtocol
    
    init(cycleArchive: RestCycleArchiveProtocol) {
        self.cycleArchive = cycleArchive
    }
    
    func manifestCycle(initiation: Date, termination: Date, quality: Int?, linkedFlows: [UUID]) {
        let prism = RestCyclePrism(
            initiationMoment: initiation,
            terminationMoment: termination,
            qualityMetric: quality,
            breathFlowLinks: linkedFlows
        )
        
        cycleArchive.appendCycle(prism)
    }
}

