//
//  IntroTraceCoordinator.swift
//  DAYTRACE
//
//  Onboarding flow coordinator
//

import UIKit

final class IntroTraceCoordinator: FlowCoordinator {
    
    let navigationController: UINavigationController
    var onComplete: (() -> Void)?
    
    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }
    
    func start() {
        print("🔵 IntroTraceCoordinator: Starting onboarding")
        let onboardingVC = OnboardingPageHost()
        onboardingVC.modalPresentationStyle = .fullScreen
        
        onboardingVC.onComplete = { [weak self] in
            print("🔵 IntroTraceCoordinator: ===== ONBOARDING COMPLETE CALLBACK =====")
            print("🔵 IntroTraceCoordinator: self exists: \(self != nil)")
            print("🔵 IntroTraceCoordinator: onComplete closure exists: \(self?.onComplete != nil)")
            
            TraceStorage.shared.hasCompletedOnboarding = true
            print("🔵 IntroTraceCoordinator: Set hasCompletedOnboarding = \(TraceStorage.shared.hasCompletedOnboarding)")
            
            self?.onComplete?()
            print("🔵 IntroTraceCoordinator: Called coordinator onComplete")
            print("🔵 IntroTraceCoordinator: ===== END CALLBACK =====")
        }
        
        navigationController.setViewControllers([onboardingVC], animated: true)
        print("🔵 IntroTraceCoordinator: Set view controllers, onComplete is set: \(onboardingVC.onComplete != nil)")
    }
}
