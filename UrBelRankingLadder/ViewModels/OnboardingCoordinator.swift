import Foundation
import Combine

@MainActor
final class OnboardingCoordinator: ObservableObject {
    @Published var hasCompletedOnboarding: Bool = false
    
    init() {
        hasCompletedOnboarding = UserDefaults.standard.bool(forKey: "hasCompletedOnboarding")
    }
    
    func completeOnboarding() {
        hasCompletedOnboarding = true
        UserDefaults.standard.set(true, forKey: "hasCompletedOnboarding")
    }
}

