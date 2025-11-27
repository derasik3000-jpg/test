import Foundation
import Combine

class MetricsConstellationViewModel: ObservableObject {
    @Published var metricsData: [MetricsRecordPrism] = []
    @Published var selectedTimespan: Int = 7
    @Published var averageSleepDuration: Double = 0
    @Published var correlationPercentage: Double = 0
    
    private let metricsUseCase: RetrieveMetricsConstellation
    private let correlationAlchemy: ComputeCorrelationAlchemy
    private let vaporArchive: VaporFlowArchiveProtocol
    private let cycleArchive: RestCycleArchiveProtocol
    
    let timespanOptions = [7, 14, 30]
    
    init(metricsUseCase: RetrieveMetricsConstellation, correlationAlchemy: ComputeCorrelationAlchemy, vaporArchive: VaporFlowArchiveProtocol, cycleArchive: RestCycleArchiveProtocol) {
        self.metricsUseCase = metricsUseCase
        self.correlationAlchemy = correlationAlchemy
        self.vaporArchive = vaporArchive
        self.cycleArchive = cycleArchive
        synthesizeStatistics()
    }
    
    func synthesizeStatistics() {
        metricsData = metricsUseCase.synthesizeMetrics(for: selectedTimespan)
        
        let recentCycles = cycleArchive.retrieveRecentCycles(threshold: selectedTimespan)
        let recentFlows = vaporArchive.retrieveRecentQuantums(threshold: selectedTimespan * 2)
        
        averageSleepDuration = recentCycles.isEmpty ? 0 : recentCycles.map { $0.phaseDurationInMinutes }.reduce(0, +) / Double(recentCycles.count)
        
        correlationPercentage = correlationAlchemy.distillCorrelation(sleepCycles: recentCycles, breathFlows: recentFlows)
    }
    
    func changeTimespan(to days: Int) {
        selectedTimespan = days
        synthesizeStatistics()
    }
}

