import SwiftUI

@main
struct TheBrozoneGentleDenApp: App {
    var body: some Scene {
        WindowGroup {
            PrimaryBootstrapContainer()
                .preferredColorScheme(.dark)
        }
    }
}

struct CoreNavigationContainer: View {

    @StateObject private var onboardingState = OnboardingStateManager()

    var body: some View {
        ZStack {
            if onboardingState.hasCompletedOnboarding {
                PrimaryTabInterface()
            } else {
                InitialConfigurationScreen(onboardingState: onboardingState)
            }
        }
    }
}
