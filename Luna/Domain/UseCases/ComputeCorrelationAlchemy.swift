import Foundation

class ComputeCorrelationAlchemy {
    func distillCorrelation(sleepCycles: [RestCyclePrism], breathFlows: [VaporFlowPrism]) -> Double {
        guard !sleepCycles.isEmpty else { return 0 }
        
        var cyclesWithFlows = 0
        
        for cycle in sleepCycles {
            let hasLinkedFlow = breathFlows.contains { flow in
                let timeDifference = abs(cycle.initiationMoment.timeIntervalSince(flow.chronoStamp))
                return timeDifference < 3600
            }
            
            if hasLinkedFlow {
                cyclesWithFlows += 1
            }
        }
        
        return (Double(cyclesWithFlows) / Double(sleepCycles.count)) * 100.0
    }
    
    func calculateAverageSleepDelta(before: [RestCyclePrism], after: [RestCyclePrism]) -> Double {
        guard !before.isEmpty, !after.isEmpty else { return 0 }
        
        let avgBefore = before.map { $0.phaseDurationInMinutes }.reduce(0, +) / Double(before.count)
        let avgAfter = after.map { $0.phaseDurationInMinutes }.reduce(0, +) / Double(after.count)
        
        return avgAfter - avgBefore
    }
}

