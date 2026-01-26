import SwiftUI
import Combine
import StoreKit

struct RootLauncherView: View {
    @StateObject private var coordinator = CoordinatorObserver.shared
    
    var body: some View {
        Group {
            if coordinator.isValidating {
                // Показываем splash во время валидации
                PremiumSplashView()
                    .onAppear {
                        Task {
                            await coordinator.startValidation()
                            
                            // Проверяем алерт оценки после валидации
                            if coordinator.checkRatingAlertEligibility() {
                                DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                                    showRatingAlert()
                                }
                            }
                        }
                    }
            } else if coordinator.shouldShowAlternativeMode {
                // Показываем альтернативный режим (WebView)
                ResearchFlowView()
            } else {
                // Показываем основное приложение
                RootNavigationView()
            }
        }
    }
    
    // MARK: - Rating Alert
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
            coordinator.markRatingAlertShown()
        })
        
        alert.addAction(UIAlertAction(title: "Later", style: .cancel) { _ in
            coordinator.markRatingAlertShown()
        })
        
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let rootViewController = windowScene.windows.first?.rootViewController {
            rootViewController.present(alert, animated: true)
        }
    }
}


