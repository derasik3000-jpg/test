import Foundation
import Combine

class CelestialNavigationOrchestrator: ObservableObject {
    @Published var currentDestination: CosmicDestination = .splash
    @Published var hasCompletedOnboarding: Bool = false
    
    init() {
        hasCompletedOnboarding = UserDefaults.standard.bool(forKey: "hasCompletedOnboarding")
    }
    
    func navigateTo(_ destination: CosmicDestination) {
        currentDestination = destination
    }
    
    func completeOnboarding() {
        hasCompletedOnboarding = true
        UserDefaults.standard.set(true, forKey: "hasCompletedOnboarding")
        currentDestination = .mainNexus
    }
    
    enum CosmicDestination: Equatable {
        case splash
        case onboarding
        case mainNexus
        case breathSession(BreathFlowCategory)
        case sleepDiary
        case statistics
        case settings
    }
}

