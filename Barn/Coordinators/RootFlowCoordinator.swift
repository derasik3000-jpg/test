//
//  RootFlowCoordinator.swift
//  DAYTRACE
//
//  Root coordinator managing app flow
//

import UIKit

final class RootFlowCoordinator: FlowCoordinator {
    
    let navigationController: UINavigationController
    private let window: UIWindow
    private var childCoordinator: FlowCoordinator?
    
    init(window: UIWindow) {
        self.window = window
        self.navigationController = UINavigationController()
        self.navigationController.setNavigationBarHidden(true, animated: false)
    }
    
    func start() {
        window.rootViewController = navigationController
        window.makeKeyAndVisible()
        
        showBootScreen()
    }
    
    private func showBootScreen() {
        let bootScene = TraceBootScene()
        bootScene.onComplete = { [weak self] in
            self?.checkOnboardingStatus()
        }
        navigationController.setViewControllers([bootScene], animated: false)
    }
    
    private func checkOnboardingStatus() {
        if TraceStorage.shared.hasCompletedOnboarding {
            showMainFlow()
        } else {
            showOnboarding()
        }
    }
    
    private func showOnboarding() {
        print("🟡 RootFlowCoordinator: Showing onboarding")
        let coordinator = IntroTraceCoordinator(navigationController: navigationController)
        coordinator.onComplete = { [weak self] in
            print("🟡 RootFlowCoordinator: Onboarding completed, showing main flow")
            self?.childCoordinator = nil // Release onboarding coordinator
            self?.showMainFlow()
        }
        childCoordinator = coordinator // Keep strong reference
        coordinator.start()
    }
    
    private func showMainFlow() {
        print("🟢 RootFlowCoordinator: Showing main flow")
        let coordinator = MainTabCoordinator(navigationController: navigationController)
        childCoordinator = coordinator // Keep strong reference
        coordinator.start()
    }
}
