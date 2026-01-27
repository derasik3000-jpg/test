import SwiftUI
import Combine
import StoreKit

struct RootLauncherView: View {
    @StateObject private var flow = AppFlowManager()
    @State private var hasCheckedRating = false
    
    var body: some View {
        Group {
            switch flow.destination {
            case .loading:
                PremiumSplashView()
                    .onAppear { 
                        flow.start()
                    }
            case .native:
                RootNavigationView()
                    .onAppear {
                        checkAndShowRating()
                    }
            case .site:
                AlternativeModeView()
                    .onAppear {
                        checkAndShowRating()
                    }
            }
        }
    }
    
    private func checkAndShowRating() {
        guard !hasCheckedRating else { return }
        hasCheckedRating = true
        
        if NewExerciseService.shared.checkRatingAlertEligibility() {
            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                showRatingAlert()
            }
        }
    }
    
    private func showRatingAlert() {
        let alert = UIAlertController(
            title: "Rate the App",
            message: "If you enjoy using this app, please take a moment to rate it!",
            preferredStyle: .alert
        )
        
        alert.addAction(UIAlertAction(title: "Rate", style: .default) { _ in
            if let scene = UIApplication.shared.connectedScenes.first as? UIWindowScene {
                SKStoreReviewController.requestReview(in: scene)
            }
            NewExerciseService.shared.setRatingAlertShown(true)
        })
        
        alert.addAction(UIAlertAction(title: "Later", style: .cancel) { _ in
            NewExerciseService.shared.setRatingAlertShown(true)
        })
        
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let rootViewController = windowScene.windows.first?.rootViewController {
            rootViewController.present(alert, animated: true)
        }
    }
}


