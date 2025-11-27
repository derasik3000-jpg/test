import Foundation

class RetrieveMetricsConstellation {
    private let vaporArchive: VaporFlowArchiveProtocol
    private let cycleArchive: RestCycleArchiveProtocol
    private let metricsArchive: MetricsArchiveProtocol
    
    init(vaporArchive: VaporFlowArchiveProtocol, cycleArchive: RestCycleArchiveProtocol, metricsArchive: MetricsArchiveProtocol) {
        self.vaporArchive = vaporArchive
        self.cycleArchive = cycleArchive
        self.metricsArchive = metricsArchive
    }
    
    func synthesizeMetrics(for daysSpan: Int) -> [MetricsRecordPrism] {
        let allCycles = cycleArchive.retrieveAllCycles()
        let allFlows = vaporArchive.retrieveAllQuantums()
        
        let calendar = Calendar.current
        var metricsCollection: [MetricsRecordPrism] = []
        
        for dayOffset in 0..<daysSpan {
            guard let targetDate = calendar.date(byAdding: .day, value: -dayOffset, to: Date()) else { continue }
            let startOfDay = calendar.startOfDay(for: targetDate)
            let endOfDay = calendar.date(byAdding: .day, value: 1, to: startOfDay)!
            
            let cyclesInDay = allCycles.filter { cycle in
                cycle.initiationMoment >= startOfDay && cycle.initiationMoment < endOfDay
            }
            
            let flowsInDay = allFlows.filter { flow in
                flow.chronoStamp >= startOfDay && flow.chronoStamp < endOfDay
            }
            
            let averageDuration = cyclesInDay.isEmpty ? 0 : cyclesInDay.map { $0.phaseDurationInMinutes }.reduce(0, +) / Double(cyclesInDay.count)
            let correlation = flowsInDay.isEmpty ? 0 : Double(flowsInDay.count) / Double(max(cyclesInDay.count, 1)) * 100
            
            let prism = MetricsRecordPrism(
                chronoMark: startOfDay,
                averagePhaseLength: averageDuration,
                sessionCorrelationValue: min(correlation, 100)
            )
            
            metricsCollection.append(prism)
        }
        
        return metricsCollection.reversed()
    }
}

