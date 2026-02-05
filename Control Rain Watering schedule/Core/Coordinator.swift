//
//  Coordinator.swift
//  Control Rain Watering schedule
//
//  Created by Евгений on 04.02.2026.
//

import UIKit

/// Base protocol for all coordinators in the farming app
protocol FarmCoordinator: AnyObject {
    var navigationController: UINavigationController { get set }
    var childCoordinators: [FarmCoordinator] { get set }
    
    func start()
    func childDidFinish(_ child: FarmCoordinator)
}

extension FarmCoordinator {
    func childDidFinish(_ child: FarmCoordinator) {
        childCoordinators.removeAll { $0 === child }
    }
}

/// Main coordinator that manages the entire app flow
final class MainHarvestCoordinator: FarmCoordinator {
    
    var navigationController: UINavigationController
    var childCoordinators: [FarmCoordinator] = []
    
    private let window: UIWindow
    private let storageManager: BarnStorageManager
    
    init(window: UIWindow) {
        self.window = window
        self.navigationController = UINavigationController()
        self.storageManager = BarnStorageManager.shared
        
        setupNavigationBarAppearance()
    }
    
    func start() {
        if storageManager.isFirstLaunch() {
            showSplashScreen()
        } else {
            showMainTabs()
        }
        
        window.rootViewController = navigationController
        window.makeKeyAndVisible()
    }
    
    private func setupNavigationBarAppearance() {
        let appearance = UINavigationBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = FarmPalette.richSoil
        appearance.titleTextAttributes = [
            .foregroundColor: FarmPalette.goldenHarvest,
            .font: FarmTypography.barn
        ]
        appearance.largeTitleTextAttributes = [
            .foregroundColor: FarmPalette.goldenHarvest,
            .font: FarmTypography.silo
        ]
        
        navigationController.navigationBar.standardAppearance = appearance
        navigationController.navigationBar.scrollEdgeAppearance = appearance
        navigationController.navigationBar.tintColor = FarmPalette.goldenHarvest
        navigationController.navigationBar.prefersLargeTitles = false
    }
    
    private func showSplashScreen() {
        let splashVC = SplashViewController()
        splashVC.onComplete = { [weak self] in
            self?.showOnboarding()
        }
        navigationController.setViewControllers([splashVC], animated: false)
    }
    
    private func showOnboarding() {
        let onboardingVC = OnboardingViewController()
        onboardingVC.onComplete = { [weak self] in
            self?.storageManager.markOnboardingComplete()
            self?.showMainTabs()
        }
        navigationController.setViewControllers([onboardingVC], animated: true)
    }
    
    private func showMainTabs() {
        let tabBarVC = FarmTabBarController()
        navigationController.setViewControllers([tabBarVC], animated: true)
    }
}
