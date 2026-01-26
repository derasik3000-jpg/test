import SwiftUI

public struct RootContainerView: View {
    @State private var showOnboarding = false
    @State private var tapCount = 0
    private let settingsRepo = ProvisionRegistry.shared.settingsRepo
    
    public init() {}
    
    public var body: some View {
        NavigationHubLayout()
            .preferredColorScheme(.dark)
            .onAppear {
                // Check UserDefaults directly for more reliability
                let hasSeenOnboarding = UserDefaults.standard.bool(forKey: "hasCompletedOnboarding")
                print("🔍 Checking onboarding status: \(hasSeenOnboarding)")
                
                if !hasSeenOnboarding {
                    showOnboarding = true
                }
            }
            .fullScreenCover(isPresented: $showOnboarding) {
                WelcomeFlowContainer(
                    viewModel: OnboardingFlowVM(settingsRepo: settingsRepo),
                    isPresented: $showOnboarding
                )
            }
    }
}

