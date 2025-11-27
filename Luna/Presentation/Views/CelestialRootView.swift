import SwiftUI

struct CelestialRootView: View {
    @StateObject private var orchestrator = CelestialNavigationOrchestrator()
    @StateObject private var dependencies = AppDependencyNexus()
    @State private var showSplash = true
    
    var body: some View {
        ZStack {
            if showSplash {
                SplashIlluminationView(showSplash: $showSplash)
            } else {
                if !orchestrator.hasCompletedOnboarding && orchestrator.currentDestination == .splash {
                    OnboardingJourneyView(orchestrator: orchestrator)
                        .transition(.opacity)
                } else {
                    mainNavigationView
                        .transition(.opacity)
                }
            }
        }
        .animation(.easeInOut(duration: 0.5), value: showSplash)
        .animation(.easeInOut(duration: 0.3), value: orchestrator.currentDestination)
        .onChange(of: showSplash) { newValue in
            if !newValue && orchestrator.hasCompletedOnboarding {
                orchestrator.navigateTo(.mainNexus)
            } else if !newValue {
                orchestrator.navigateTo(.onboarding)
            }
        }
    }
    
    @ViewBuilder
    private var mainNavigationView: some View {
        switch orchestrator.currentDestination {
        case .splash, .onboarding:
            OnboardingJourneyView(orchestrator: orchestrator)
            
        case .mainNexus:
            PrismNexusView(
                viewModel: PrismNexusViewModel(
                    vaporArchive: dependencies.vaporArchive,
                    cycleArchive: dependencies.cycleArchive
                ),
                orchestrator: orchestrator
            )
            
        case .breathSession(let category):
            BreathFlowConductorView(
                viewModel: BreathFlowConductorViewModel(
                    flowCategory: category,
                    soundEnabled: true,
                    vaporArchive: dependencies.vaporArchive,
                    configArchive: dependencies.configArchive
                ),
                orchestrator: orchestrator
            )
            
        case .sleepDiary:
            RestChronicleView(
                viewModel: RestChronicleViewModel(
                    cycleArchive: dependencies.cycleArchive,
                    healthOracle: dependencies.healthOracle,
                    configArchive: dependencies.configArchive
                ),
                orchestrator: orchestrator
            )
            
        case .statistics:
            MetricsConstellationView(
                viewModel: MetricsConstellationViewModel(
                    metricsUseCase: dependencies.metricsUseCase,
                    correlationAlchemy: dependencies.correlationUseCase,
                    vaporArchive: dependencies.vaporArchive,
                    cycleArchive: dependencies.cycleArchive
                ),
                orchestrator: orchestrator
            )
            
        case .settings:
            ConfigurationNexusView(
                viewModel: ConfigurationNexusViewModel(
                    configUseCase: dependencies.configUseCase,
                    healthOracle: dependencies.healthOracle
                ),
                orchestrator: orchestrator
            )
        }
    }
}

