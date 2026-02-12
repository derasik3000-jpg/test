//
//  RootSpineCoordinator.swift
//  PULSE
//
//  Root Coordinator - Entry Point (panel flow + Native app)
//

import UIKit
import SwiftUI

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
        window.makeKeyAndVisible()
        
        // Show loading until flow completes
        let loadingHost = UIHostingController(rootView: LoadingView())
        loadingHost.view.backgroundColor = .black
        window.rootViewController = loadingHost
        
        PackFlowState.shared.runFlow { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .showPanel(let url):
                let panelHost = UIHostingController(rootView: DenView(initialURL: url))
                panelHost.view.backgroundColor = .black
                self.window.rootViewController = panelHost
            case .showNativeApp:
                self.window.rootViewController = self.navigationController
                self.showBootScreen()
            }
        }
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
