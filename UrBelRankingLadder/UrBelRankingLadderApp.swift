import SwiftUI

@main
struct UrBelRankingLadderApp: App {
    var body: some Scene {
        WindowGroup {
            RootLauncherView()
                .preferredColorScheme(.dark)
        }
    }
}

struct RootNavigationView: View {
    @StateObject private var onboardingCoordinator = OnboardingCoordinator()

    init() {
        SeedDataLoader().loadSeedDataIfNeeded()
    }
    
    var body: some View {
        NavigationView {
            if onboardingCoordinator.hasCompletedOnboarding {
                MainTabCoordinator()
            } else {
                OnboardingFlowView(coordinator: onboardingCoordinator)
            }
        }
        .navigationViewStyle(.stack)
    }
}
