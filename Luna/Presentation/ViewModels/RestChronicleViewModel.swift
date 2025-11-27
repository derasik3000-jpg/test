import Foundation
import Combine

class RestChronicleViewModel: ObservableObject {
    @Published var cyclePrisms: [RestCyclePrism] = []
    @Published var isLoadingQuantums: Bool = false
    @Published var showHealthKitPrompt: Bool = false
    
    private let cycleArchive: RestCycleArchiveProtocol
    private let healthOracle: AetherHealthOracle
    private let configArchive: ConfigurationArchiveProtocol
    
    init(cycleArchive: RestCycleArchiveProtocol, healthOracle: AetherHealthOracle, configArchive: ConfigurationArchiveProtocol) {
        self.cycleArchive = cycleArchive
        self.healthOracle = healthOracle
        self.configArchive = configArchive
        loadCycleHistory()
    }
    
    func loadCycleHistory() {
        cyclePrisms = cycleArchive.retrieveAllCycles()
        
        let config = configArchive.retrieveConfiguration()
        if config.healthDataSyncEnabled {
            synchronizeHealthKitData()
        }
    }
    
    func synchronizeHealthKitData() {
        isLoadingQuantums = true
        
        let endDate = Date()
        let startDate = Calendar.current.date(byAdding: .day, value: -30, to: endDate)!
        
        healthOracle.fetchRestCycleNebula(from: startDate, to: endDate) { [weak self] healthCycles in
            DispatchQueue.main.async {
                for cycle in healthCycles {
                    self?.cycleArchive.appendCycle(cycle)
                }
                self?.cyclePrisms = self?.cycleArchive.retrieveAllCycles() ?? []
                self?.isLoadingQuantums = false
            }
        }
    }
    
    func addManualCycle(start: Date, end: Date, quality: Int?, comment: String?) {
        let prism = RestCyclePrism(
            initiationMoment: start,
            terminationMoment: end,
            qualityMetric: quality,
            commentNote: comment
        )
        cycleArchive.appendCycle(prism)
        loadCycleHistory()
    }
    
    func requestHealthKitAccess() {
        healthOracle.requestCosmicPermission { [weak self] success, error in
            DispatchQueue.main.async {
                if success {
                    var config = self?.configArchive.retrieveConfiguration() ?? ConfigurationPrism()
                    config.healthDataSyncEnabled = true
                    self?.configArchive.modifyConfiguration(config)
                    self?.synchronizeHealthKitData()
                }
                self?.showHealthKitPrompt = false
            }
        }
    }
}

