//
//  RootSpineCoordinator.swift
//  PULSE
//
//  Root Coordinator - Entry Point
//

import UIKit

class RootSpineCoordinator: Coordinator {
    var childCoordinators: [Coordinator] = []
    var navigationController: UINavigationController
    
    private let window: UIWindow
    
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
        let bootScene = PulseBootScene()
        bootScene.coordinator = self
        navigationController.pushViewController(bootScene, animated: false)
    }
    
    func bootCompleted() {
        if hasCompletedOnboarding() {
            showMainOrbit()
        } else {
            showOnboarding()
        }
    }
    
    private func hasCompletedOnboarding() -> Bool {
        return UserDefaults.standard.bool(forKey: "hasCompletedOnboarding")
    }
    
    private func showOnboarding() {
        let onboardingCoordinator = IntroPulseCoordinator(navigationController: navigationController)
        onboardingCoordinator.parentCoordinator = self
        addChild(onboardingCoordinator)
        onboardingCoordinator.start()
    }
    
    func onboardingCompleted() {
        UserDefaults.standard.set(true, forKey: "hasCompletedOnboarding")
        showMainOrbit()
    }
    
    private func showMainOrbit() {
        let mainCoordinator = MainOrbitCoordinator(navigationController: navigationController)
        addChild(mainCoordinator)
        mainCoordinator.start()
    }
}
