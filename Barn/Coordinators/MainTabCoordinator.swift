//
//  MainTabCoordinator.swift
//  DAYTRACE
//
//  Main tab bar coordinator
//

import UIKit

final class MainTabCoordinator: FlowCoordinator {
    
    let navigationController: UINavigationController
    
    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }
    
    func start() {
        print("🟢 MainTabCoordinator: ===== STARTING MAIN TAB BAR =====")
        print("🟢 MainTabCoordinator: Creating UITabBarController")
        let tabBarController = UITabBarController()
        
        // Configure tab bar appearance
        let appearance = UITabBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = ColorPalette.surface
        
        // Style for normal state
        appearance.stackedLayoutAppearance.normal.iconColor = ColorPalette.primary.withAlphaComponent(0.5)
        appearance.stackedLayoutAppearance.normal.titleTextAttributes = [
            .foregroundColor: ColorPalette.primary.withAlphaComponent(0.5)
        ]
        
        // Style for selected state
        appearance.stackedLayoutAppearance.selected.iconColor = ColorPalette.primary
        appearance.stackedLayoutAppearance.selected.titleTextAttributes = [
            .foregroundColor: ColorPalette.primary
        ]
        
        tabBarController.tabBar.standardAppearance = appearance
        tabBarController.tabBar.scrollEdgeAppearance = appearance
        
        print("🟢 MainTabCoordinator: Creating child coordinators")
        let todayCoordinator = TodayCoordinator()
        let timelineCoordinator = TimelineCoordinator()
        let profileCoordinator = ProfileCoordinator()
        
        print("🟢 MainTabCoordinator: Starting child coordinators")
        todayCoordinator.start()
        timelineCoordinator.start()
        profileCoordinator.start()
        
        print("🟢 MainTabCoordinator: Setting view controllers")
        tabBarController.viewControllers = [
            todayCoordinator.navigationController,
            timelineCoordinator.navigationController,
            profileCoordinator.navigationController
        ]
        
        print("🟢 MainTabCoordinator: View controllers count: \(tabBarController.viewControllers?.count ?? 0)")
        print("🟢 MainTabCoordinator: Setting tab bar as root in navigation controller")
        navigationController.setViewControllers([tabBarController], animated: true)
        print("🟢 MainTabCoordinator: ===== TAB BAR SET SUCCESSFULLY =====")
    }
}
