import SwiftUI
import Combine

class AppDependencyNexus: ObservableObject {
    let persistenceController: ZephyrPersistenceController
    let healthOracle: AetherHealthOracle
    
    let vaporArchive: VaporFlowArchiveProtocol
    let cycleArchive: RestCycleArchiveProtocol
    let metricsArchive: MetricsArchiveProtocol
    let configArchive: ConfigurationArchiveProtocol
    
    let initiateFlowUseCase: InitiateVaporFlowCeremony
    let concludeFlowUseCase: ConcludeVaporFlowCeremony
    let appendCycleUseCase: AppendRestCycleManifestation
    let metricsUseCase: RetrieveMetricsConstellation
    let correlationUseCase: ComputeCorrelationAlchemy
    let configUseCase: ModifyConfigurationCeremony
    
    init() {
        self.persistenceController = ZephyrPersistenceController.nebula
        self.healthOracle = AetherHealthOracle.celestialInstance
        
        self.vaporArchive = VaporFlowCoreArchive(cosmosController: persistenceController)
        self.cycleArchive = RestCycleCoreArchive(cosmosController: persistenceController)
        self.metricsArchive = MetricsCoreArchive(cosmosController: persistenceController)
        self.configArchive = ConfigurationCoreArchive(cosmosController: persistenceController)
        
        self.initiateFlowUseCase = InitiateVaporFlowCeremony(vaporArchive: vaporArchive)
        self.concludeFlowUseCase = ConcludeVaporFlowCeremony(vaporArchive: vaporArchive)
        self.appendCycleUseCase = AppendRestCycleManifestation(cycleArchive: cycleArchive)
        self.metricsUseCase = RetrieveMetricsConstellation(vaporArchive: vaporArchive, cycleArchive: cycleArchive, metricsArchive: metricsArchive)
        self.correlationUseCase = ComputeCorrelationAlchemy()
        self.configUseCase = ModifyConfigurationCeremony(configArchive: configArchive)
    }
}

