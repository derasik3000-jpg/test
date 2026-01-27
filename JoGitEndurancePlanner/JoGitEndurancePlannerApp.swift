import SwiftUI

@main
struct JoGitEndurancePlannerApp: App {
    var body: some Scene {
        WindowGroup {
            RootLauncherView()
                .preferredColorScheme(.dark)
        }
    }
}

struct RootNavigationView: View {
    @State private var hasCompletedOnboarding: Bool
    
    init() {
        let _ = PersistenceCoordinator.shared
        let completed = OnboardingStateManager.shared.hasCompletedOnboarding
        _hasCompletedOnboarding = State(initialValue: completed)
        print("[ROOT] 🔍 RootNavigationView init - hasCompletedOnboarding: \(completed)")
    }
    
    var body: some View {
        NavigationView {
            Group {
                if hasCompletedOnboarding {
                    MainTabView()
                } else {
                    OnboardingView(onComplete: {
                        OnboardingStateManager.shared.markAsCompleted()
                        hasCompletedOnboarding = true
                    })
                }
            }
        }
        .navigationViewStyle(.stack)
        .onAppear {
            let completed = OnboardingStateManager.shared.hasCompletedOnboarding
            print("[ROOT] RootNavigationView appeared - hasCompletedOnboarding: \(completed)")
            if completed != hasCompletedOnboarding {
                hasCompletedOnboarding = completed
            }
        }
    }
}
